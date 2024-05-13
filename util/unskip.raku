#!/usr/bin/env raku

use File::Temp;

use lib 'lib';
use Test-Files;

=begin overview

Many examples in the docs are tagged with :skip-test. This utility
checks to see if the code can be run with our usual tester, and if
that fails, with the C<:solo> attribute; If either of these work,
the file is modified in place, allowing the developer to inspect
the changes to the C<doc/> directory and commit the updated files.

This utility will also attempt to remove C<:solo>'s from tests that
are being run; sometimes the attribute is copied unecessarily to a
new test. Because it's longer to run the test with this attribute,
we want to avoid it if possible.

As with C<xt/> tests, you can limit the files checked with the
C<TEST_FILES> environment variable or by passing the named files as arguments

=end overview

# Return a list of skippable positions in this file.
sub get-tries($file) {
    say "$file: Calculating tests to re-try";
    my @tries;
    # $line-no is 0-based
    for $file.IO.slurp.lines.kv -> $line-no, $line {
        if $line ~~ / ^ \s* '=' .* << 'code' >> .* ':skip-test'/ {
            @tries.push: {
                'line' => $line-no,
                'type' => 'skip'
            }
        }
        elsif $line ~~ / ^ \s* '=' .* << 'code' >> .* ':solo'/ {
            @tries.push: {
                'line' => $line-no,
                'type' => 'solo'
            }
        }
    }
    return @tries;
}

my $test-script = 'xt/examples-compilation.rakutest';

# Can this file pass the examples compilation test?
sub run-ok($file) {
    my $proc = Proc::Async.new($*EXECUTABLE, $test-script, $file, :out, :err);

    # ignore the output, just care about the exitcode
    $proc.stdout.tap: {;};
    $proc.stderr.tap: {;};

    return $proc.start.result.exitcode == 0;
}

sub remove-skip($file, $skip-pos, :$solo=False) {
    my ($test-file, $test-io) = tempfile(:suffix<.rakudoc>, :!unlink);

    for $file.IO.slurp.lines.kv -> $pos, $line  {
        if $pos == $skip-pos {
            if $line ~~ / (.*) \s+ ':skip-test' / {
                $test-io.print: ~$0;
                if $solo {
                    $test-io.print: ' :solo';
                }
                $test-io.print: "\n";
            } else {
                say "$file: Unexpected error occurred";
                dd $test-file, $pos, $skip-pos, $line;
            }
        } else {
            $test-io.say: $line;
        }
    }
    $test-io.close;

    return $test-file;
}

sub remove-solo($file, $skip-pos) {
    my ($test-file, $test-io) = tempfile(:suffix<.rakudoc>, :!unlink);

    for $file.IO.slurp.lines.kv -> $pos, $line  {
        if $pos == $skip-pos {
            if $line ~~ / (.*) \s+ ':solo' / {
                $test-io.print: ~$0;
                $test-io.print: "\n";
            } else {
                say "$file: Unexpected error occurred";
                dd $test-file, $pos, $skip-pos, $line;
            }
        } else {
            $test-io.say: $line;
        }
    }
    $test-io.close;

    return $test-file;
}

Test-Files.pods.race(:batch(1)).map: -> $file {
    say "$file: PROCESSING";

    my @tries = get-tries($file);

    if !@tries {
        say "$file: no :skip-test/:solo present";
        next;
    }

    # Make sure the file runs without error as is.
    if !run-ok($file) {
        say "$file: does not pass in its current state";
        next;
    }
    my $skip-pos = 0;
    my $good-file = $file;

    while $skip-pos < @tries.elems {
        # For each skip-test, test a run that doesn't include the skip.
        my $skip-line = @tries[$skip-pos]<line>;
        my $working-file;

        if @tries[$skip-pos]<type> eq 'solo' {
            say "$file: Trying to !solo at {$skip-line+1}";
            $working-file = remove-solo($good-file, $skip-line);
            if run-ok($working-file) {
                say "$file: :solo not needed";
                $good-file = $working-file;
                @tries = get-tries($good-file);
                # Leave skip-pos where it was, as that :solo has been removed.
             } else {
                say "$file: :solo still needed";
                $skip-pos++;
             }
        } elsif @tries[$skip-pos]<type> eq 'skip' {
            $working-file = remove-skip($good-file, $skip-line);

            say "$file: trying to unskip at {$skip-line+1}";

            if run-ok($working-file) {
                say "$file: :skip-test not needed";
                # Point to this new good copy as our good version
                $good-file = $working-file;
                @tries = get-tries($good-file);
                # Leave skip-pos where it was, as that position has been removed.
            } else {
                # If that didn't work, test it with :solo
                say "$file: Trying to :solo at {$skip-line+1}";
                $working-file = remove-skip($good-file, $skip-line, :solo);
                if run-ok($working-file) {
                    say "$file: :skip-test switched to :solo";
                    # Point to this new good copy as our good version
                    $good-file = $working-file;
                    @tries = get-tries($good-file);
                    # Leave skip-pos where it was, as that position has been removed.
                } else {
                    say "$file: :skip-test still required";
                    # If that didn't work, then we try the next position
                    $skip-pos++;
                }
            }
        }
    }
    # Put our last good version of the file back.
    copy $good-file, $file;
}

say "Completed - please use `git status` to see any updated files";
