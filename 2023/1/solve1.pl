#!/usr/bin/env perl

use v5.16;
use warnings;

my $sum = 0;
while (<>) {
	chomp;

	my ($d1) = $_ =~ /^[^\d]*?(\d)/;
	my ($d2) = $_ =~ /(\d)[^\d]*$/;

	my $num = "$d1$d2";
	$sum += (0 + $num);
}

say $sum;
