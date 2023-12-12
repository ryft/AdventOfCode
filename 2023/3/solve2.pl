#!/usr/bin/env perl

use v5.16;
use warnings;

my $sum = 0;

my @lines = <STDIN>;
chomp(@lines);

my $linelen = length($lines[0]);

my %stars;

for my $line_idx (0 .. scalar(@lines) - 1) {
    my $line = $lines[$line_idx];
    my $remaining = $line;

    # How many left chars have we skipped now?
    my $offset = 0;

    while ($remaining) {
        # Chop any leading non-digits, adjust offset
        if ($remaining =~ /^([^\d]+)/) {
            my $lead = $1;
            $remaining =~ s/^[^\d]+//;
            #say "remaining chopped to $remaining";
            $offset += length($lead);
            #say "offset is now $offset";
        }

        # Should only be false if we've hit the end
        if ($remaining =~ /^(\d+)/) {
            my $num = $1;
            my $valid = 0;

            my $prev_idx = $offset - 1;
            my $next_idx = $offset + length($num);
            #say "prev_idx=$prev_idx, next_idx=$next_idx";

            # Check for immediate neighbours on same line
            if (idx_is_star($line, $prev_idx)) {
                record_star_num($line_idx, $prev_idx, $num);
            }
            if (idx_is_star($line, $next_idx)) {
                record_star_num($line_idx, $next_idx, $num);
            }

            # Check for neighbours on previous line
            if ($line_idx > 0) {
                for my $idx ($prev_idx .. $next_idx) {
                    if (idx_is_star($lines[$line_idx - 1], $idx)) {
                        record_star_num($line_idx - 1, $idx, $num);
                    }
                }
            }

            # Check for neighbours on next line
            if ($line_idx < scalar(@lines) - 1) {
                for my $idx ($prev_idx .. $next_idx) {
                    if (idx_is_star($lines[$line_idx + 1], $idx)) {
                        record_star_num($line_idx + 1, $idx, $num);
                    }
                }
            }

            # Now chop off the number we've just recorded
            $remaining =~ s/^$num//;
            $offset += length($num);
        }
    }
}

for my $star (keys %stars) {
    my @nums = @{ $stars{$star} };

    if (@nums == 2) {
        $sum += ($nums[0] * $nums[1]);
    }
}

sub record_star_num {
    my ($line_idx, $char_idx, $num) = @_;

    $stars{"$line_idx.$char_idx"} ||= [];
    push @{ $stars{"$line_idx.$char_idx"} }, $num;
}

sub idx_is_star {
    my ($input, $idx) = @_;

    if (!$idx < 0 || $idx > length($input) - 1) {
        return 0;
    }

    my $char = substr($input, $idx, 1);

    if ($char eq '*') {
        return 1;
    } else {
        return 0;
    }
}

say $sum;
