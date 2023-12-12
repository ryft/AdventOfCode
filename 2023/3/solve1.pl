#!/usr/bin/env perl

use v5.16;
use warnings;

my $sum = 0;

my @lines = <STDIN>;
chomp(@lines);

my $linelen = length($lines[0]);

for my $line_idx (0 .. scalar(@lines) - 1) {
    my $line = $lines[$line_idx];
    my $remaining = $line;

    # How many left chars have we skipped now?
    my $offset = 0;

    my @valid_nums;

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
            if (my $char = (idx_is_symbol($line, $prev_idx) || idx_is_symbol($line, $next_idx))) {
                say "$num looks good due to immediate neighbour ($char)";
                $valid = 1;
            }

            # Check for neighbours on previous line
            if (!$valid && $line_idx > 0) {
                for my $idx ($prev_idx .. $next_idx) {
                    if (!$valid and my $char = idx_is_symbol($lines[$line_idx - 1], $idx)) {
                        say "$num looks good due to previous line idx $idx ($char)";
                        $valid = 1;
                    }
                }
            }

            # Check for neighbours on next line
            if (!$valid && $line_idx < scalar(@lines) - 1) {
                for my $idx ($prev_idx .. $next_idx) {
                    if (!$valid and my $char = idx_is_symbol($lines[$line_idx + 1], $idx)) {
                        say "$num looks good due to next line idx $idx ($char)";
                        $valid = 1;
                    }
                }
            }

            push (@valid_nums, $num) if $valid;

            # Now chop off the number we've just recorded
            $remaining =~ s/^$num//;
            $offset += length($num);
        }
    }

    $sum += $_ for @valid_nums;

    say "line " . ($line_idx + 1) . " valid nums: " . join(', ', @valid_nums) . " (sum now $sum)";
}

sub idx_is_symbol {
    my ($input, $idx) = @_;

    if (!$idx < 0 || $idx > length($input) - 1) {
        return 0;
    }

    my $char = substr($input, $idx, 1);

    if ($char =~ /([^\w.])/) {
        return $1;
    } else {
        return 0;
    }
}

say $sum;
