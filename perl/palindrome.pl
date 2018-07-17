#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $word = shift;

if (reverse($word) eq $word){
	say $word . " is a palindrome";
}
else{
	say $word . " is not a palindrome";
}
