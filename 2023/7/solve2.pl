#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);
use List::MoreUtils qw(uniq zip);
use List::Util qw(max);

my @all_cards = qw(J 2 3 4 5 6 7 8 9 T Q K A);
my @all_card_vals = (0 .. 12);
my %card_strength = zip @all_cards, @all_card_vals;

my @hands = <STDIN>;
chomp(@hands);

# Precompute strengths, not needed but it's late and perl is an arse
@hands = map {
    my ($trick, $bid) = split /\s+/;
    {
        trick => $trick,
        bid => $bid,
        trick_strength => get_trick_strength($trick),
        card_strengths => [ map { $card_strength{$_} } (split //, $trick) ],
    };
} @hands;

# Sort hands ascending
sub compare_tricks {
    $a->{trick_strength} <=> $b->{trick_strength}
 || $a->{card_strengths}->[0] <=> $b->{card_strengths}->[0]
 || $a->{card_strengths}->[1] <=> $b->{card_strengths}->[1]
 || $a->{card_strengths}->[2] <=> $b->{card_strengths}->[2]
 || $a->{card_strengths}->[3] <=> $b->{card_strengths}->[3]
 || $a->{card_strengths}->[4] <=> $b->{card_strengths}->[4]
}
@hands = sort compare_tricks @hands;

# Calculate total winnings
my $winnings = 0;
for my $i (0 .. scalar(@hands) - 1) {
    $winnings += ($hands[$i]->{bid} * ($i + 1));
}

#say dump(\@hands);
say $winnings;

sub get_trick_strength {
    my $hand = shift;

    # Jokers? Get rid I say
    my $jokers = ($hand =~ s/J//g) || 0;

    # Here's a thought... surely the best bet is always to add copies
    # of the same card up to the number of jokers because we have no
    # straights or suits
    my @candidates = uniq(map { $hand . join('', ($_) x $jokers) } (grep { $_ ne 'J' } @all_cards));

    return max(map { _get_trick_strength($_) } @candidates);
}

# After joker replacement
sub _get_trick_strength {
    my $hand = shift;

    my %cards;
    $cards{$_}++ for (split //, $hand);

    # Sort cards in order of which we have most
    my @best_cards = sort { $cards{$b} <=> $cards{$a} } keys(%cards);

    if ($cards{$best_cards[0]} == 5) {
        return 6;
    } elsif ($cards{$best_cards[0]} == 4) {
        return 5;
    } elsif ($cards{$best_cards[0]} == 3 && $cards{$best_cards[1]} == 2) {
        return 4;
    } elsif ($cards{$best_cards[0]} == 3) {
        return 3;
    } elsif ($cards{$best_cards[0]} == 2 && $cards{$best_cards[1]} == 2) {
        return 2;
    } elsif ($cards{$best_cards[0]} == 2) {
        return 1;
    } else {
        return 0;
    }
}

sub get_card_strength {
    my $hand = shift;

    $hand =~ /^(\w)/ and return $card_strength{$1};
}
