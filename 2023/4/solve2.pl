#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my @lines = <STDIN>;
chomp(@lines);

my $sum = scalar @lines;

my %card_num_copies;

for my $card (@lines) {
    if ($card =~ /Card\s+(\d+):([\d\s]*)\|([\d\s]*)$/) {
        my ($card_num, $left, $right) = ($1, $2, $3);

        my %winning = map { $_ => 1 } (split /\s+/, $left);
        my @ours = split /\s+/, $right;

        #say dump(\%winning);
        #say dump(\@ours);

        my $wins = 0;
        for my $num (@ours) {
            $wins++ if $num && $winning{$num};
        }

        my $card_points = $wins;# ? (2 ** ($wins - 1)) : 0;
        my $card_copies = ($card_num_copies{$card_num} || 0) + 1;

        # Now we add the copied cards to the tally
        for my $copied_card_num ($card_num + 1 .. $card_num + $card_points) {
            $card_num_copies{$copied_card_num} += $card_copies;
        }

        say "Card $card_num (x $card_copies): $card_points point(s), adding $card_copies copies of "
            . "(" . ($card_num + 1) . " .. " . ($card_num + $card_points) . ")";
    }
}

for my $copies (values %card_num_copies) {
    $sum += $copies;
}

say $sum;
