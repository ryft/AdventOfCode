#!/usr/bin/env perl

# First problem I consulted the subreddit for!
# I should do these earlier in the day.
#
# Spoiler: the input is carefully crafted such that each start state
# reaches a goal state after x steps, where x is the length of the loop.

use v5.16;
use warnings;

use Data::Dump qw(dump);

my @lines = <STDIN>;
chomp(@lines);

my @directions = split //, shift @lines;
my $total_dirs = scalar @directions;

my %nodes;
for my $line (@lines) {
    if ($line =~ /(\w{3}) = \((\w{3}), (\w{3})\)/) {
        $nodes{$1} = { L => $2, R => $3 };
    }
}

my @start_nodes = grep { $_ =~ /A$/ } keys(%nodes);
my @loop_lengths = ();

for my $node (@start_nodes) {
    my $steps = 0;
    while ($node !~ /Z$/) {
        my $next_dir = $directions[$steps % $total_dirs];

        $node = $nodes{$node}->{$next_dir};
        $steps++;
    }
    push @loop_lengths, $steps;
}

say lcm_list(@loop_lengths);

sub lcm_list {
    my $a = shift;

    for my $b (@_) {
        $a = lcm($a, $b);
    }

    return $a;
}

sub lcm {
    my ($a, $b) = @_;

    return ($a * $b) / gcd($a, $b);
}

sub gcd {
    my ($a, $b) = @_;

    # Cheers Euclid
    return $b unless $a;
    return gcd($b % $a, $a);
}
