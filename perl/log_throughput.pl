#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my %log_count = ();

while (<STDIN>) {
	chomp;
	$log_count{$_}++;
}

while(my ($timestamp,$count) = each(%log_count)) {
	say "$timestamp: $count";
}