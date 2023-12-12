#!/usr/bin/env perl

# Optimisation ideas:
#
# 1. Precompute all soil => location mappings, removing a lot of lookups
#
#
# 2. When looking up a mapped value, store an additional trivial entry
#       `src => [1, offset]`
#    This seemed to make things a lot worse so that's not worth optimising.
#
# 3. NYTProf tells me that `sort` is causing massive slowdown in map_value
#
#    Removed the call to sort, I don't _think_ it's necessary.
#
# 4. Cache soil => location mappings once we've looked them up once
#
#    Literally no benefit.
#
# 5. Parallelise seed evaluations

use v5.16;
use warnings;

use lib qw(/home/vagrant/perl5/lib/perl5/x86_64-linux-thread-multi);

use Data::Dump qw(dump);
use List::MoreUtils qw(natatime);
use List::Util qw(pairs sum);
use Parallel::ForkManager;

my @lines = <STDIN>;
chomp(@lines);

# Get target seeds from first line
my $seed_str = shift @lines;
my @seed_pairs = pairs(grep { m/^\d+$/ } (split /\s+/, $seed_str));
my $total_seeds = sum(map { $_->[1] } @seed_pairs);
say "Total seeds to evaluate: $total_seeds";

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
my $pm = Parallel::ForkManager->new(6);
$pm->run_on_finish(sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;

    my ($seed, $location) = @$data;

    say "Got result from worker for seed group $ident: best seed=$seed, location=$location";
});

say 'Evaluating seeds...';
LOOP:
for my $pair (@seed_pairs) {
    my ($start, $length) = @$pair;
    my $pid = $pm->start($start) and next LOOP;

    my $lowest_location;
    my $best_seed;

    for my $i (0 .. $length - 1) {
        my $seed = $start + $i;

        my $soil = map_value($seed_soil_map, $seed);
        my $fert = map_value($soil_fert_map, $soil);
        my $watr = map_value($fert_watr_map, $fert);
        my $ligt = map_value($watr_ligt_map, $watr);
        my $temp = map_value($ligt_temp_map, $ligt);
        my $humd = map_value($temp_humd_map, $temp);
        my $loca = map_value($humd_loca_map, $humd);

        if (!defined $lowest_location or $loca < $lowest_location) {
            $lowest_location = $loca;
            $best_seed = $seed;
        }
    }

    $pm->finish(0, [$best_seed, $lowest_location]);
}
$pm->wait_all_children;

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

#say "Seed $best_seed in location $lowest_location";
