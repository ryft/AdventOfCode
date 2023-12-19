#!/usr/bin/env perl

use v5.16;
use warnings;

use lib qw(/home/vagrant/perl5/lib/perl5/x86_64-linux-thread-multi);

use Data::Dump qw(dump);
use List::Util qw(all any);

my @lines = <STDIN>;
chomp(@lines);

my $expansion_factor = 1000000;

my @input_grid = map { [ split // ] } @lines;
my @grid = expand_grid(@input_grid);
#say dump(\@grid);

my $max_y = $#grid;
my $max_x = scalar(@{ $grid[0] }) - 1;

my %galaxies;
my $idx = 0;
for my $y (0 .. $max_y) {
    for my $x (0 .. $max_x) {
        $galaxies{$idx++} = [$y, $x] if $grid[$y][$x] eq '#';
    }
}
#say dump(\%galaxies);

my $sum = 0;
for my $g1 (0 .. keys(%galaxies) - 1) {
    for my $g2 ($g1 + 1 .. keys(%galaxies) - 1) {
        $sum += path_length($g1, $g2);
    }
}

say "Sum of shortest paths: $sum";

sub path_length {
    my ($i1, $i2) = @_;

    my ($x1, $y1) = @{ $galaxies{$i1} };
    my ($x2, $y2) = @{ $galaxies{$i2} };

    my $x_diff = abs($x2 - $x1);
    my $y_diff = abs($y2 - $y1);

    return $x_diff + $y_diff;
}

sub expand_grid {
    my @input = @_;
    my @expanded = @input;

    my @cols_to_expand;
    for my $x (0 .. scalar(@{ $expanded[0] }) - 1) {
        if (all { $_->[$x] eq '.' } @expanded) {
            push @cols_to_expand, $x;
            say "col $x *";
        } else {
            say "col $x";
        }
    }

    # Expand rows by iterating in reverse
    for my $x (reverse @cols_to_expand) {
        say "expanding col $x";
        for my $y (0 .. $#expanded) {
            my @row_arr = @{ $expanded[$y] };
            splice @row_arr, $x, 1, ('.') x $expansion_factor;
            $expanded[$y] = \@row_arr;
        }
    }

    my @expanded_2;

    my $row_idx = 0;
    say "$#expanded rows to expand";
    for my $row (@expanded) {
        say "row " . $row_idx++;
        if (any { $_ =~ /#/ } @{ $input[$row_idx] }) {
            push @expanded_2, $row;
        } else {
            push @expanded_2, ($row) x $expansion_factor;
        }
    }

    return @expanded_2;
}
