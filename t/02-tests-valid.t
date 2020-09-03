#!/usr/bin/env raku

use v6;
use lib $*PROGRAM.parent(2).child('lib');
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test-Files;

=begin overview

Ensure any test file, including author tests, have clean syntax and POD

=end overview

my @files = Test-Files.files.grep({$_.ends-with: '.t'});

if @files {
    plan +@files;
} else {
    plan :skip-all<No test files specified>
}

my %data;
my $lock = Lock.new;

my $verbose = %*ENV<P6_DOC_TEST_VERBOSE> // False;

@files.race.map: -> $file {
    react {
        my $proc = Proc::Async.new([$*EXECUTABLE-NAME, '-c', $file]);

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
    ok %data{$file}, "$file Pod6 and syntax check out";
}


# vim: expandtab shiftwidth=4 ft=perl6
