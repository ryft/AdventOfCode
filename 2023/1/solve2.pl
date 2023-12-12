#!/usr/bin/env perl

use v5.16;
use warnings;

use Data::Dump qw(dump);

my @digits = qw(zero one two three four five six seven eight nine);
my $i = 0;
my %digitmap = map { $_ => $i++ } @digits;

my $sum = 0;
while (<>) {
    chomp;
    my $in = $_;

    # Iterate in both directions so we're sure we get both
    # first and last replacements
    my $out_fw = replace_in_order($in, 0);
    my $out_rv = replace_in_order($in, 1);

    my ($d1) = $out_fw =~ /^[^\d]*?(\d)/;
    my ($d2) = $out_rv =~ /(\d)[^\d]*$/;

    my $num = "$d1$d2";
    $sum += (0 + $num);
}

# Need to find and replace digits in the order they appear
sub replace_in_order {
    my ($in, $flip) = @_;

    my $out = $flip ? reverse($in) : $in;
    my %map;
    if ($flip) {
        for my $d (keys %digitmap) {
            $map{reverse $d} = $digitmap{$d};
        }
    } else {
        %map = %digitmap;
    }

    my $done = 0;
    while (!$done) {
        if (my $new = iter($out, \%map)) {
            $out = $new;
        } else {
            $done = 1;
        }
    }

    return $flip ? reverse($out) : $out;
}

# Iterate over string until we replace a string
# Return undef if no replacements possible
sub iter {
    my ($in, $map) = @_;
    my $out = $in;

    for my $substr_len (1 .. length($in)) {
        my $sub = substr($in, 0, $substr_len);

        for my $d (keys %$map) {
            if ($sub =~ /$d/) {
                $out =~ s/$d/$map->{$d}/;
            }
        }

        return $out if $out ne $in;
    }

    return;
}

say $sum;
