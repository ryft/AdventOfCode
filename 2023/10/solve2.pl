#!/user/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);
use List::Util qw(min max);

# Big Idea for part 2: once we've found the nodes in the path, iterate
# over each row in the grid and:
# * Find the left- and right-mode nodes on this grid line
# * Count the number of non-path tiles between the two
# * Exclude any that are preceded by and _even_ number of path tiles
#
# This doesn't work quite right as we need to introduce a concept of a
# "vertical boundary", i.e. if you're inside the loop and you see a "-"
# then you're still considered to be inside.

# Coordinate system has the origin in the top-left
# Grid squares are addressed as (y, x) for convenience

my @lines = <STDIN>;
chomp(@lines);

my $start = find_start();
my @grid  = map { [ split // ] } @lines;

my $max_y = scalar(@grid) - 1;
my $max_x = scalar(@{ $grid[0] }) - 1;

my %seen_a = ($start->[0] => { $start->[1] => 1 });
my %seen_b = ($start->[0] => { $start->[1] => 1 });

# Generalises to a trivial breadth first search
# But we search in 2 "directions" at once
my ($start_a, $start_b) = get_neighbours($start);

my $depth = search([$start_a], [$start_b]);
say "Farthest point found at depth $depth";

# We need to resolve the start node to its real pipe for the next bit
my $start_tile = resolve_pipe($start);
$grid[$start->[0]][$start->[1]] = $start_tile;
say "Start tile is actually a '$start_tile' pipe section";

my $sum = 0;
for my $y (0 .. $max_y) {
    my ($left_x, $right_x);

    for my $x (0 .. $max_x) {
        if ($seen_a{$y}{$x} || $seen_b{$y}{$x}) {
            $left_x //= $x;
            $right_x = $x;
        }
    }
    next unless defined($left_x) and defined($right_x);

    #say "Row $y: ($left_x .. $right_x)";

    my @enclosed_xs = ();
    my ($boundaries, $norths, $souths) = (0) x 3;

    for my $x ($left_x .. $right_x) {
        #say "\tconsidering x=$x...";

        # Must be on the final path to be eligible as a boundary node
        my $on_path = $seen_a{$y}{$x} || $seen_b{$y}{$x};

        if ($on_path) {
            # A north and south exiting pipe counts as a vertical boundary
            if ($on_path && $grid[$y][$x] =~ /[|LJ]/) {
                $norths++;
            }
            if ($on_path && $grid[$y][$x] =~ /[|7F]/) {
                $souths++;
            }

            while ($norths > 0 && $souths > 0) {
                $boundaries++;
                $norths--;
                $souths--;
            }

        } else {
            if ($boundaries % 2 != 0) {
                #say "\t\tis a non-path and boundaries=$boundaries, including";
                push @enclosed_xs, $x;
            } else {
                #say "\t\tis a non-path and boundaries=$boundaries, excluding";
            }
        }
    }

    #say "\tenclosed_xs: " . dump(\@enclosed_xs);
    $sum += scalar(@enclosed_xs);
}
say "Sum of all enclosed nodes: $sum";

sub is_boundary {
    my $node = shift;
    my ($y, $x) = @$node;

    # Must be on the final path to be eligible as a boundary node
    return unless $seen_a{$y}{$x} or $seen_b{$y}{$x};

    # A pipe is trivially a vertical boundary
    # Arbitrarily choose anything to connect to south to also be one
    my $this = $grid[$y][$x];
    return 1 if $this =~ /[|7F]/;

    return;
}

sub search {
    my ($frontier_a, $frontier_b) = @_;
    my $depth = 1;

    while ($depth < 1_000_000) {
        my ($this_a, $this_b) = (shift @$frontier_a, shift $frontier_b);
        #say "Searching depth $depth, current state:"
        #    . " A=$grid[$this_a->[0]][$this_a->[1]]" . dump($this_a)
        #    . " B=$grid[$this_b->[0]][$this_b->[1]]" . dump($this_b);

        # Mark these nodes as having been visited
        $seen_a{$this_a->[0]}{$this_a->[1]} = 1;
        $seen_b{$this_b->[0]}{$this_b->[1]} = 1;

        # Only need to consider one neighbour each time
        my ($next_a) = grep { !$seen_a{$_->[0]}{$_->[1]} } get_neighbours($this_a);
        my ($next_b) = grep { !$seen_b{$_->[0]}{$_->[1]} } get_neighbours($this_b);

        #say "\tRoute A => $grid[$next_a->[0]][$next_a->[1]]" . dump($next_a);
        #say "\tRoute B => $grid[$next_b->[0]][$next_b->[1]]" . dump($next_b);

        if ($seen_b{$next_a->[0]}{$next_a->[1]} || $seen_a{$next_b->[0]}{$next_b->[1]}) {
            # If next node has been seen by the other search, exit
            #say 'Paths met!';
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

sub resolve_pipe {
    my $node = shift;
    my ($y, $x) = @$node;

    my %connections;

    if ($y > 0) {
        my $north = $grid[$y-1][$x];
        $connections{north} = 1 if $north =~ /[|7F]/;
    }

    if ($x < $max_x) {
        my $east = $grid[$y][$x+1];
        $connections{east} = 1 if $east =~ /[-J7]/;
    }

    if ($y < $max_y) {
        my $south = $grid[$y+1][$x];
        $connections{south} = 1 if $south =~ /[|LJ]/;
    }

    if ($x > 0) {
        my $west = $grid[$y][$x-1];
        $connections{west} = 1 if $west =~ /[-LF]/;
    }

    if ($connections{north}) {
        return '|' if $connections{south};
        return 'J' if $connections{west};
        return 'L' if $connections{east};
    } elsif ($connections{south}) {
        return '7' if $connections{west};
        return 'F' if $connections{east};
    } elsif ($connections{east}) {
        return '-' if $connections{west};
    }

    die 'Cannot resolve pipe tile at ' . dump($node);
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
