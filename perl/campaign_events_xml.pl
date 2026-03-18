#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use XML::Generator;
use POSIX qw(strftime);

# Written in 2013.
# Perl script extracts email/event data from a database and converts it into a structured XML file.

my $dsn      = "DBI:Pg:dbname=your_db;host=localhost";
my $user     = "your_user";
my $password = "your_password";

my $dbh = DBI->connect($dsn, $user, $password, {
    RaiseError => 1,
    AutoCommit => 0,
}) or die "Database connection failed";

# DATE HELPER
sub interpolate_date {
    my ($template) = @_;
    my $date = strftime("%Y-%m-%d", localtime);
    $template =~ s/#Y-#m-#d/$date/g;
    return $template;
}

my $xml_header = qq{<Honda_SSDIF>
<Header>
  <SourceSystemID>ESP</SourceSystemID>
  <FileDate>#Y-#m-#d</FileDate>
  <SSDIFVersion>1</SSDIFVersion>
</Header>
<Data>};

print interpolate_date($xml_header), "\n";

my $xml = XML::Generator->new(pretty => 2);

my $SequenceNumber = 0;

my $sql = 'DECLARE honda_xml_cursor CURSOR WITHOUT HOLD FOR ' . sql();

$dbh->begin_work;

eval { $dbh->do($sql) };
if ($@){
    warn $@;
    $dbh->rollback;
    exit;
}

while (1){
    my $sth = $dbh->prepare("FETCH 10000 FROM honda_xml_cursor");
    $sth->execute;
    last unless $sth->rows;

    foreach my $contact (@{ $sth->fetchall_arrayref({}) }) {

        my @elements;
        $SequenceNumber++;

        my %elements = (
            RecordCoding => {
                SequenceNumber => $SequenceNumber,
                DateOfCapture  => $contact->{event_date},
            },
            Entity => {
                EntityURN => $contact->{EntityURN},
            },
            EmailBouncebacks => {
                EmailAddress        => $contact->{email},
                EmailAddressStatus  => $contact->{EmailAddressStatus},
                BouncebackReason    => $contact->{BouncebackReason},
                EmailReadDate       => $contact->{event_date},
                EmailSentDate       => $contact->{launch_date},
            },
            ExternalReference => {
                ExternalSystem     => 'ESP',
                ExternalRefExtKey  => $contact->{contact_id},
            },
        );

        # unsubscribe only
        $elements{SubjectPrefs} = {
            SubjectPrefValue => '4',
            PrefSuppType     => $contact->{PrefSuppType},
        } if $contact->{event} eq 'unsubscribe_click';

        # active contacts only
        $elements{ContactWithHonda} = {
            ContactType      => 'I',
            ContactPoint     => 'B',
            ContactMedium    => 'E',
            Source           => 'M',
            CRCode           => $contact->{CRCode},
            Comment          => comment_lookup($contact->{Comment}, $contact->{link_label}),
            ContactDate      => $contact->{event_date},
            InboundMedium    => 'E',
            ResponseType     => $contact->{ResponseType},
            ResponseStatus   => $contact->{ResponseStatus},
            InboundExecution => 'X',
            ClickToAction    => $contact->{link_label},
            ClickToActionURL => $contact->{click_url},
            CampaignDivision => undef,
            ActivityType     => undef,
            SequenceNumber   => undef,
            CellRef          => undef,
            OutboundMedium   => undef,
            DataSource       => undef,
            OutboundExecution=> undef,
        } if $contact->{EmailAddressStatus} eq 'ACTV';

        # campaign parsing
        if (defined $contact->{CampCode} && $contact->{EmailAddressStatus} eq 'ACTV'){
            $elements{ContactWithHonda}{CampaignDivision} = substr($contact->{CampCode}, 0, 1);
            $elements{ContactWithHonda}{ActivityType}     = substr($contact->{CampCode}, 1, 1);
            $elements{ContactWithHonda}{SequenceNumber}   = substr($contact->{CampCode}, -4, 4);
        }

        # comm parsing
        if (defined $contact->{CommCode} && $contact->{EmailAddressStatus} eq 'ACTV'){
            $elements{ContactWithHonda}{CellRef}           = substr($contact->{CommCode}, 0, 2);
            $elements{ContactWithHonda}{OutboundMedium}    = substr($contact->{CommCode}, 2, 1);
            $elements{ContactWithHonda}{DataSource}        = substr($contact->{CommCode}, 3, 2);
            $elements{ContactWithHonda}{OutboundExecution} = substr($contact->{CommCode}, -1, 1);
        }

        # build XML
        for my $element (keys %elements){

            my @items;
            my %items = %{ $elements{$element} };

            for my $name (keys %items) {
                push @items, $xml->$name($items{$name});
            }

            push @elements, $xml->$element(@items);
        }

        print $xml->Record(@elements), "\n";
    }
}

$dbh->do('CLOSE honda_xml_cursor');
$dbh->commit;

print qq{</Data>
</Honda_SSDIF>
};

sub sql {
    return qq{
        SELECT
            contact_id,
            email,
            user_campaignattribute_campcode AS "CampCode",
            user_campaignattribute_commcode AS "CommCode",
            user_campaignattribute_entityurn AS "EntityURN",
            '2026-03-17' AS event_date,
            '2026-03-15' AS launch_date,
            'click' AS event,
            'ACTV' AS "EmailAddressStatus",
            'AB99' AS "CRCode",
            'TDR' AS link_label,
            'https://example.com' AS click_url,
            'EMC' AS "ResponseType",
            'V' AS "ResponseStatus",
            'X' AS "BouncebackReason",
            'CTA' AS "Comment"
        FROM eventlog
    };
}

sub comment_lookup {
    my ($comment, $link_label) = @_;

    if (defined($comment) && ($comment eq 'eNews Email opened' || $comment eq 'eNews Unsubscribed')){
        return $comment;
    }

    my $comments = {
        TDR => 'CTA_Test_Drive_or_Ride',
        BR  => 'CTA_Brochure_Request',
        C   => 'CTA_Competition',
    };

    return defined($link_label) ? $comments->{$link_label} : 'CTA_Other';
}
