#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my @numbers = qw{
	1
    22
    32
    0
    1911
    -452
    234
};

my @sorted = sort { $a <=> $b } @numbers;

my $min = $sorted[0];
my $max = $sorted[-1];

say "Min: " . $min;
say "Max: " . $max;