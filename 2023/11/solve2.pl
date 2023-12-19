#!/usr/bin/env perl

use v5.16;
use warnings;

use lib qw(/home/vagrant/perl5/lib/perl5/x86_64-linux-thread-multi);

use Data::Dump qw(dump);
use List::Util qw(all min max);

my @lines = <STDIN>;
chomp(@lines);

my $expansion_factor = 1000000;

my @grid = map { [ split // ] } @lines;

# Store the rows and columns that are duplicated
my (@dup_y, @dup_x);
expand_grid(@grid);

my $max_y = $#grid;
my $max_x = scalar(@{ $grid[0] }) - 1;

my %galaxies;
my $idx = 0;
for my $y (0 .. $max_y) {
    for my $x (0 .. $max_x) {
        $galaxies{$idx++} = [$y, $x] if $grid[$y][$x] eq '#';
    }
}
#say dump(\@grid);
#say dump(\@dup_y);
#say dump(\@dup_x);
#say dump(\%galaxies);

my $sum = 0;
for my $g1 (0 .. keys(%galaxies) - 1) {
    for my $g2 ($g1 + 1 .. keys(%galaxies) - 1) {
        #say "galaxy $g1 -> $g2: " . path_length($g1, $g2);
        $sum += path_length($g1, $g2);
    }
}

say "Sum of shortest paths: $sum";

sub path_length {
    my ($i1, $i2) = @_;

    my ($y1, $x1) = @{ $galaxies{$i1} };
    my ($y2, $x2) = @{ $galaxies{$i2} };

    my ($y_min, $y_max) = (min($y1, $y2), max($y1, $y2));
    my ($x_min, $x_max) = (min($x1, $x2), max($x1, $x2));

    # Loop over duplicated areas of space, see if we need to account
    # for those when measuring distances
    my ($y_offset, $x_offset) = (0, 0);

    for my $y (@dup_y) {
        if ($y >= $y_min && $y <= $y_max) {
            #say "y_min=$y_min <= dup_y=$y <= y_max=$y_max, adding offset";
            $y_offset += $expansion_factor - 1;
        }
    }
    for my $x (@dup_x) {
        if ($x >= $x_min && $x <= $x_max) {
            #say "x_min=$x_min <= dup_x=$x <= x_max=$x_max, adding offset";
            $x_offset += $expansion_factor - 1;
        }
    }

    my $y_diff = $y_max - $y_min + $y_offset;
    my $x_diff = $x_max - $x_min + $x_offset;

    return $y_diff + $x_diff;
}

sub expand_grid {
    for my $y (0 .. $#grid) {
        if (all { $_ eq '.' } @{ $grid[$y] }) {
            push @dup_y, $y;
        }
    }

    for my $x (0 .. scalar(@{ $grid[0] }) - 1) {
        if (all { $_->[$x] eq '.' } @grid) {
            push @dup_x, $x;
        }
    }
}
