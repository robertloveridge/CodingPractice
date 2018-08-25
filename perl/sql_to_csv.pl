#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use Carp;
use File::Temp;
use File::Copy;
use Text::CSV_XS;
use Getopt::Long;

my $db_name = q{chinook.db};
my $sql = q{SELECT * FROM employees};
my $output_path = q{/Users/rob/Documents};
my $output_name = q{employees.csv};

GetOptions (
  "db_name=s" => \$db_name,
  "sql=s" => \$sql,
  "output_path=s" => \$output_path,
  "output_name=s" => \$output_name)
  or die("Error in command line arguments\n");

# only allow SELECT statements
croak "Not a SELECT: '$sql'" unless ( $sql =~ m{ ^ [ ]* SELECT }ixms );

my $dsn = sprintf("dbi:SQLite:dbname=%s",$db_name);

# no username or password set
my $dbh = DBI->connect($dsn, q{}, q{}, { RaiseError => 1 })
   or die $DBI::errstr;

my $results = $dbh->prepare($sql);
$results->execute;

my $fh = File::Temp->new;
my $csv = Text::CSV_XS->new({
 binary 	=> 1,
 eol 	=> "\r\n",
});

my @header_row = @{$results->{NAME}};
$csv->print($fh, \@header_row);

while (my $row = $results->fetchrow_hashref) {
	my @row = @{$row}{@header_row};
	$csv->print($fh, \@row);
}

$fh->flush;
my $output = $output_path . q{/} . $output_name;
copy($fh->filename, $output);

exit();
