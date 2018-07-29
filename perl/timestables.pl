#!/usr/bin/perl

use strict;
use warnings;

use Text::TabularDisplay;

# Write a program that prints a multiplication table for numbers up to 12.

my $table = Text::TabularDisplay->new(qw(1 2 3 4 5 6 7 8 9 10 11 12));
for my $primary (1..12){
  my @row = ();
  for my $secondary (1..12){
    push @row, $primary * $secondary;
  }
  $table->add(@row);
}
print $table->render . "\n";
