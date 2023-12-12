#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my @lines = <STDIN>;
chomp(@lines);

my (undef, @times) = split /\s+/, $lines[0];
my (undef, @dists) = split /\s+/, $lines[1];

my $product = 1;

for my $race (0 .. @times-1) {
    say "Race $race";

    my $winning_strategies = 0;
    for my $speed (0 .. $times[$race]) {
        my $distance = $speed * ($times[$race] - $speed);
        #say "Hold for ${speed}ms: travel ${distance}mm";

        if ($distance > $dists[$race]) {
            $winning_strategies++;
        }
    }
    $product *= $winning_strategies;
}

say $product;
