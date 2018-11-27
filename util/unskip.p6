#!/usr/bin/env perl6

use v6;

use File::Temp;

use lib 'lib';
use Test-Files;

=begin overview

Many examples in the docs are tagged with :skip-test. This utility
checks to see if the code can be run with our usual tester, and if
that fails, with the C<:solo> attribute; If either of these work,
the file is modified in place, allowing the developer to inspect
the changes to the C<doc/> directory and commit the updated files.

=end overview

# Return a list of skippable positions in this file.
sub get-skips($file) {
    say "    Calculating skips";
    my @skips;
    # $line-no is 0-based
    for $file.IO.slurp.lines.kv -> $line-no, $line {
        next unless $line ~~ / ^ \s* '=' .* << 'code' >> .* ':skip-test'/;
        @skips.push: $line-no;
    }
    return @skips;
}

my $test-script = 'xt/examples-compilation.t';

# Can this file pass the examples compilation test?
sub run-ok($file) {
    my $proc = Proc::Async.new($*EXECUTABLE, $test-script, $file, :out, :err);

    # ignore the output, just care about the exitcode
    $proc.stdout.tap: {;};
    $proc.stderr.tap: {;};

    return $proc.start.result.exitcode == 0;
}

sub remove-skip($file, $skip-pos, :$solo=False) {
    my ($test-file, $test-io) = tempfile(:suffix<.pod6>, :!unlink);

    for $file.IO.slurp.lines.kv -> $pos, $line  {
        if $pos == $skip-pos {
            if $line ~~ / (.*) \s+ ':skip-test' / {
                $test-io.print: ~$0;
                if $solo {
                    $test-io.print: ' :solo';
                }
                $test-io.print: "\n";
            } else {
                say "Unexpected error occurred";
                dd $test-file, $pos, $skip-pos, $line;
            }
        } else {
            $test-io.say: $line;
        }
    }
    $test-io.close;

    return $test-file;
}

for Test-Files.pods -> $file {
    say "PROCESSING: $file";

    my @skips = get-skips($file);

    if !@skips {
        say "    no :skip-test present";
        next;
    }

    # Make sure the file runs without error as is.
    if !run-ok($file) {
        say "    does not pass in its current state";
        next;
    }
    my $skip-pos = 0;
    my $good-file = $file;

    while $skip-pos < @skips.elems {
        # For each skip-test, test a run that doesn't include the skip.
        my $skip-line = @skips[$skip-pos];
        my $working-file = remove-skip($good-file, $skip-line);

        say "    Trying to unskip at {$skip-line+1}";

        if run-ok($working-file) {
            say "    :skip-test not needed";
            # Point to this new good copy as our good version
            $good-file = $working-file;
            @skips = get-skips($good-file);
            # Leave skip-pos where it was, as that position has been removed.
        } else {
            # If that didn't work, test it with :solo
            say "    Trying to :solo at {$skip-line+1}";
            $working-file = remove-skip($good-file, $skip-line, :solo);
            if run-ok($working-file) {
                say "    :skip-test switched to :solo";
                # Point to this new good copy as our good version
                $good-file = $working-file;
                @skips = get-skips($good-file);
                # Leave skip-pos where it was, as that position has been removed.
            } else {
                say "    :skip-test still required";
                # If that didn't work, then we try the next position
                $skip-pos++;
            }
        }
    }
    # Put our last good version of the file back.
    copy $good-file, $file;
}

say "Completed - please use `git status` to see any updated files";
