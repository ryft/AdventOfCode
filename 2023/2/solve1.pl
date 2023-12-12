#!/usr/bin/env perl

use v5.16;
use warnings;

my $sum = 0;

my %max = (
    red => 12,
    green => 13,
    blue => 14,
);

while (<>) {
    chomp;

    my ($game_id, $game_str) = ($_ =~ /^Game (\d+): (.*)$/);

    my @games = split /;\s*/, $game_str;

    my $possible = 1;
    for my $game (@games) {
        my @selections = split /,\s*/, $game;

        for my $selection (@selections) {
            my ($total, $colour) = ($selection =~ /^(\d+) (\w+)$/);
            if ($total > $max{$colour}) {
                $possible = 0;
            }
        }
    }

    $sum += $game_id if $possible;
}

say $sum;
