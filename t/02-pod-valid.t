#!/usr/bin/env raku

use lib $*PROGRAM.parent(2).child('lib');
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test-Files;

=begin overview

Ensure any text that isn't a code example is valid C<Pod6>.

=end overview

my @files = Test-Files.pods;
plan +@files;

my %data;
my $lock = Lock.new;

my $verbose = %*ENV<P6_DOC_TEST_VERBOSE>;

@files.race.map: -> $file {
    react {
        my $proc = Proc::Async.new([$*EXECUTABLE-NAME, '-c', '--doc', $file]);

        whenever $proc.stdout.lines {
            ; #discard
        }

        whenever $proc.stderr.lines {
            # An error occurred
            $verbose and diag("$file error: $_");
            $lock.protect: {
                %data{$file} = False;
            };
        }

        whenever $proc.start {
            $verbose and diag("processing $file");
            $lock.protect: {
                if %data{$file}:!exists {
                    %data{$file} = !.exitcode;  # 0 = True, anything else False
                }
            };
            done;
        }
    }
}

for %data.keys.sort -> $file {
    ok %data{$file}, "$file has clean Pod6";
}

# vim: expandtab shiftwidth=4 ft=perl6
