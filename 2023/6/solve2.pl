#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my $time = 53717880;
my $record = 275118112151524;

my $winning_strategies = 0;

# Yes I am aware that half the computations are useless because it's
# symmetrical, can't believe how easy it was to brute force though
for my $speed (0 .. $time) {
    if ($speed % 1000 == 0) {
        print "\r" . int(($speed / 53717880.0) * 100.0) . '%';
    }

    my $distance = $speed * ($time - $speed);
    #say "Hold for ${speed}ms: travel ${distance}mm";

    if ($distance > $record) {
        $winning_strategies++;
    }
}
print "\r";

say $winning_strategies;
