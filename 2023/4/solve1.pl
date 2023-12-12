#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my $sum = 0;

while (<>) {
    chomp;

    if ($_ =~ /:([\d\s]*)\|([\d\s]*)$/) {
        my ($left, $right) = ($1, $2);

        my %winning = map { $_ => 1 } (split /\s+/, $left);
        my @ours = split /\s+/, $right;

        #say dump(\%winning);
        #say dump(\@ours);

        my $wins = 0;

        for my $num (@ours) {
            $wins++ if $num && $winning{$num};
        }

        my $card_total = $wins ? (2 ** ($wins - 1)) : 0;
        $sum += $card_total;

        say "$wins win(s): card total $card_total, new sum $sum";
    }
}

say $sum;
