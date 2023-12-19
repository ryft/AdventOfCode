#!/user/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);
use List::Util qw(min max);

# Coordinate system has the origin in the top-left
# Grid squares are addressed as (y, x) for convenience

my @lines = <STDIN>;
chomp(@lines);

my $start = find_start();
my @grid  = map { [ split // ] } @lines;

my $max_y = scalar(@grid) - 1;
my $max_x = scalar(@{ $grid[0] }) - 1;

my %seen_a;
my %seen_b;

# Generalises to a trivial breadth first search
# But we search in 2 "directions" at once
my ($start_a, $start_b) = get_neighbours($start);

my $depth = search([$start_a], [$start_b]);
say "Farthest point found at depth $depth";

sub search {
    my ($frontier_a, $frontier_b) = @_;
    my $depth = 1;

    while ($depth < 1_000_000) {
        my ($this_a, $this_b) = (shift @$frontier_a, shift $frontier_b);
        say "Searching depth $depth, current state:"
            . " A=$grid[$this_a->[0]][$this_a->[1]]" . dump($this_a)
            . " B=$grid[$this_b->[0]][$this_b->[1]]" . dump($this_b);

        # Mark these nodes as having been visited
        $seen_a{$this_a->[0]}{$this_a->[1]} = 1;
        $seen_b{$this_b->[0]}{$this_b->[1]} = 1;

        # Only need to consider one neighbour each time
        my ($next_a) = grep { !$seen_a{$_->[0]}{$_->[1]} } get_neighbours($this_a);
        my ($next_b) = grep { !$seen_b{$_->[0]}{$_->[1]} } get_neighbours($this_b);

        say "\tRoute A => $grid[$next_a->[0]][$next_a->[1]]" . dump($next_a);
        say "\tRoute B => $grid[$next_b->[0]][$next_b->[1]]" . dump($next_b);

        if ($seen_b{$next_a->[0]}{$next_a->[1]} || $seen_a{$next_b->[0]}{$next_b->[1]}) {
            # If next node has been seen by the other search, exit
            say 'Paths met!';
            return $depth;

        } else {
            # Otherwise update the frontiers and keep searching
            push @$frontier_a, $next_a;
            push @$frontier_b, $next_b;
            $depth++;
        }
    }
}

sub get_neighbours {
    my $node = shift;
    #say "getting neighbours for node " . dump($node);
    my ($y, $x) = @$node;
    my $this = $grid[$y][$x];

    # Clockwise from top
    my @neighbours;

    if ($y > 0 and $this =~ /[|LJS]/) {
        my $north = $grid[$y-1][$x];
        push (@neighbours, [$y-1, $x]) if $north =~ /[|7F]/;
    }

    if ($x < $max_x and $this =~ /[-LFS]/) {
        my $east = $grid[$y][$x+1];
        push (@neighbours, [$y, $x+1]) if $east =~ /[-J7]/;
    }

    if ($y < $max_y and $this =~ /[|7FS]/) {
        my $south = $grid[$y+1][$x];
        push (@neighbours, [$y+1, $x]) if $south =~ /[|LJ]/;
    }

    if ($x > 0 and $this =~ /[-J7S]/) {
        my $west = $grid[$y][$x-1];
        push (@neighbours, [$y, $x-1]) if $west =~ /[-LF]/;
    }

    return @neighbours;
}

sub find_start {
    my $y = 0;
    my $x;
    while (!defined $x) {
        my $index = index($lines[$y], 'S');
        if ($index != -1) {
            $x = $index;
        } else {
            $y++;
        }
    }
    return [$y, $x];
}
