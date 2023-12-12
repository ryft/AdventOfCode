#!/usr/bin/env perl

use v5.16;
use warnings;

my $sum = 0;

while (<>) {
    chomp;

    my ($game_id, $game_str) = ($_ =~ /^Game (\d+): (.*)$/);

    my @games = split /;\s*/, $game_str;

    my %game_min = (
        red => 0,
        green => 0,
        blue => 0,
    );

    for my $game (@games) {
        my @selections = split /,\s*/, $game;

        for my $selection (@selections) {
            my ($total, $colour) = ($selection =~ /^(\d+) (\w+)$/);

            if ($game_min{$colour} < $total) {
                $game_min{$colour} = $total;
            }
        }
    }

    $sum += ($game_min{red} * $game_min{green} * $game_min{blue});
}

say $sum;
