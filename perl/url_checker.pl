#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

# Write a script that takes a URL as its argument and indicates whether the page 
# can be successfully reached or not. If the page cannot be successfully reached, 
# attempt to deduce why not and output a reason.

my $url = shift;

my $user_agent = LWP::UserAgent->new;
my $response = $user_agent->get($url);

if ($response->is_success) {
	print "Yeah, I can access " . $url . "\n";
}
else {
	die $response->status_line;
}
