#!/usr/bin/env perl

use v5.16;;
use warnings;

use lib qw(/home/vagrant/perl5/lib/perl5/x86_64-linux-thread-multi);

use Data::Dump qw(dump);
use List::Util qw(all sum);

my @lines = <STDIN>;
chomp(@lines);

my @extrapolated;
for my $line (@lines) {
    my @sequence = split /\s+/, $line;
    push @extrapolated, extrapolate(0, @sequence);
}

say sum(@extrapolated);

sub extrapolate {
    my ($depth, @seq) = @_;
    my @diffs;
    #say "level $depth seq:   " . dump(\@seq);
    
    my $a = shift @seq;
    my $b;
    while (@seq) {
        $b = shift @seq;
        push @diffs, ($b - $a);
        $a = $b;
    }
    #say "level $depth diffs: " . dump(\@diffs);

    if (all { !$_ } @diffs) {
        # We've hit a level with all zeros, pass back diff
        return $b;

    } else {
        # Non-zero differences, keep recursing
        my $diff = extrapolate($depth + 1, @diffs);
        my $next = $b + $diff;

        #say "level $depth extrapolated: $b + $diff = $next";
        return $next;
    }
}
