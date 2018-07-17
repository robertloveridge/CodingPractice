#!/usr/bin/perl

use strict;
use warnings;

# Write a script that takes a list of email addresses on STDIN and outputs the 10 
# most common domains (including counts).

my %domains;

# loop the input data from STDIN
while (<STDIN>){
	chomp;
	
	# get the local part and the domain
	my ($local, $domain) = split(/@/, $_);
	$domains{$domain}++;
}

my @sorted_domains = sort { $domains{$b} <=> $domains{$a} } keys %domains;

my $count = 0;
foreach my $domain (@sorted_domains) {
	last if $count == 10;
	$count++;
	printf "%s => %d\n", $domain, $domains{$domain};
}
