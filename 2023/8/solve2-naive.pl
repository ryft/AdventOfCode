#!/usr/bin/env perl

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

my @current_nodes = grep { $_ =~ /A$/ } keys(%nodes);
my $steps = 0;
while (grep { $_ !~ /Z$/ } @current_nodes) {
    my $next_dir = $directions[$steps % $total_dirs];
    my @next_nodes = map { $nodes{$_}->{$next_dir} } @current_nodes;

    #say "step $steps: ($next_dir): " . dump(\@current_nodes) . " => " . dump(\@next_nodes);

    @current_nodes = @next_nodes;
    $steps++;
}

say $steps;
