#!/usr/bin/env perl

use v5.16;
use warnings;

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

my $node = 'AAA';
my $steps = 0;
while ($node ne 'ZZZ') {
    my $next_dir = $directions[$steps % $total_dirs];

    $node = $nodes{$node}->{$next_dir};
    $steps++;
}

say $steps;
