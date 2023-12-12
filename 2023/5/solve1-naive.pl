#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my @lines = <STDIN>;
chomp(@lines);

# Get target seeds from first line
my $seed_str = shift @lines;
my @seeds = grep { m/^\d+$/ } (split /\s+/, $seed_str);

# Parse and expand all maps from inputs in almanac
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

        for my $i (0 .. $length - 1) {
            $map{$src_start + $i} = $dst_start + $i;
        }
    }

    return \%map;
}

# Now find the seed with the lowest location
my %seed_location_map;
my $lowest_location;
my $best_seed;

say 'Evaluating seeds...';
for my $seed (@seeds) {
    my $soil = $seed_soil_map->{$seed} // $seed;
    my $fert = $soil_fert_map->{$soil} // $soil;
    my $watr = $fert_watr_map->{$fert} // $fert;
    my $ligt = $watr_ligt_map->{$watr} // $watr;
    my $temp = $ligt_temp_map->{$ligt} // $ligt;
    my $humd = $temp_humd_map->{$temp} // $temp;
    my $loca = $humd_loca_map->{$humd} // $humd;

    $seed_location_map{$seed} = $loca;

    if (!defined $lowest_location or $loca < $lowest_location) {
        $lowest_location = $loca;
        $best_seed = $seed;
    }
}

say "Seed $best_seed in location $lowest_location";
