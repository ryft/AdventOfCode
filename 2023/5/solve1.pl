#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my @lines = <STDIN>;
chomp(@lines);

# Get target seeds from first line
my $seed_str = shift @lines;
my @seeds = grep { m/^\d+$/ } (split /\s+/, $seed_str);

# Parse all maps from inputs in almanac
say 'Building maps...';
my $seed_soil_map = get_next_map();
my $soil_fert_map = get_next_map();
my $fert_watr_map = get_next_map();
my $watr_ligt_map = get_next_map();
my $ligt_temp_map = get_next_map();
my $temp_humd_map = get_next_map();
my $humd_loca_map = get_next_map();

sub get_next_map {
    while (@lines and $lines[0] !~ /^[\d\s]+$/) {
        shift @lines;
    }

    my %map;
    while (@lines and $lines[0] =~ /^[\d\s]+$/) {
        my $line = shift @lines;
        my ($dst_start, $src_start, $length) = split /\s+/, $line;

        my $offset = $dst_start - $src_start;
        $map{$src_start} = [$length, $offset];
    }

    return \%map;
}

# Now find the seed with the lowest location
my %seed_location_map;
my $lowest_location;
my $best_seed;

say 'Evaluating seeds...';
for my $seed (@seeds) {
    my $soil = map_value($seed_soil_map, $seed);
    my $fert = map_value($soil_fert_map, $soil);
    my $watr = map_value($fert_watr_map, $fert);
    my $ligt = map_value($watr_ligt_map, $watr);
    my $temp = map_value($ligt_temp_map, $ligt);
    my $humd = map_value($temp_humd_map, $temp);
    my $loca = map_value($humd_loca_map, $humd);

    $seed_location_map{$seed} = $loca;

    if (!defined $lowest_location or $loca < $lowest_location) {
        $lowest_location = $loca;
        $best_seed = $seed;
    }
}

sub map_value {
    my ($map, $src_idx) = @_;

    for my $src (sort keys %$map) {
        my ($length, $offset) = @{ $map->{$src} };

        if ($src_idx >= $src && $src_idx < $src + $length) {
            return $src_idx + $offset;
        }
    }

    return $src_idx;
}

say "Seed $best_seed in location $lowest_location";
