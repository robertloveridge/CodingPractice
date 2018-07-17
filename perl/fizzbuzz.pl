#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

for (1..100){

	if (multiple_of(3, $_) && multiple_of(7, $_)){
		say $_ . ': FizzBuzz';
	}
	elsif(multiple_of(3, $_)){
		say $_ . ': Fizz';
	}
	elsif(multiple_of(7, $_)){
		say $_ . ': Buzz';
	}
}

sub multiple_of {
	my ($multiple, $test_number) = @_;
	return 1 if (($test_number % $multiple) == 0);
}
