#!/usr/bin/env perl

use v5.16;
use warnings;

use lib qw(/home/vagrant/perl5/lib/perl5/x86_64-linux-thread-multi);

use List::Util qw(pairs sum);
use Parallel::ForkManager;

my @lines = <STDIN>;
chomp(@lines);

# Get target seeds from first line
my $seed_str = shift @lines;
my @seed_pairs = pairs(grep { m/^\d+$/ } (split /\s+/, $seed_str));

# Parse all maps from inputs in almanac
say 'Building maps...';
my $soil_seed_map = get_next_map();
my $fert_soil_map = get_next_map();
my $watr_fert_map = get_next_map();
my $ligt_watr_map = get_next_map();
my $temp_ligt_map = get_next_map();
my $humd_temp_map = get_next_map();
my $loca_humd_map = get_next_map();

sub get_next_map {
    while (@lines and $lines[0] !~ /^[\d\s]+$/) {
        shift @lines;
    }

    my %map;
    while (@lines and $lines[0] =~ /^[\d\s]+$/) {
        my $line = shift @lines;
        my ($dst_start, $src_start, $length) = split /\s+/, $line;

        my $offset = $src_start - $dst_start;
        $map{$dst_start} = [$length, $offset];
    }

    return \%map;
}

my $pm = Parallel::ForkManager->new(6);

say 'Preparing location partitions...';
my $max_location = int(100_000_000 / 6);
my @parts = [
    [ map { $_ * 6 + 0 } (0 .. $max_location) ],
    [ map { $_ * 6 + 1 } (0 .. $max_location) ],
    [ map { $_ * 6 + 2 } (0 .. $max_location) ],
    [ map { $_ * 6 + 3 } (0 .. $max_location) ],
    [ map { $_ * 6 + 4 } (0 .. $max_location) ],
    [ map { $_ * 6 + 5 } (0 .. $max_location) ],
];

my $best_seed;
my $best_loca;

say 'Evaluating locations...';
LOOP:
for my $part (@parts) {
    my $pid = $pm->start and next LOOP;

    my $loca = 0;

    for my $loca (@$part) {
        my $humd = map_value($loca_humd_map, $loca);
        my $temp = map_value($humd_temp_map, $humd);
        my $ligt = map_value($temp_ligt_map, $temp);
        my $watr = map_value($ligt_watr_map, $ligt);
        my $fert = map_value($watr_fert_map, $watr);
        my $soil = map_value($fert_soil_map, $fert);
        my $seed = map_value($soil_seed_map, $soil);

        if (is_valid_seed($seed)) {
            say "Valid seed found: seed $seed @ location $loca";
            $best_seed //= $seed;
            $best_loca //= $loca;
            last;
        }
    }

    $pm->finish;
}
$pm->wait_all_children;

sub is_valid_seed {
    my $seed = shift;

    for my $pair (@seed_pairs) {
        my ($start, $length) = @$pair;
        if ($seed >= $start && $seed < $start + $length) {
            return 1;
        }
    }
    return;
}

sub map_value {
    my ($map, $src_idx) = @_;

    for my $src (keys %$map) {
        my ($length, $offset) = @{ $map->{$src} };

        if ($src_idx >= $src && $src_idx < $src + $length) {
            return $src_idx + $offset;
        }
    }

    return $src_idx;
}

say "Seed $best_seed in location $best_loca";
