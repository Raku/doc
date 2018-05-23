#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test-Files;

my $degree = %*ENV<TEST_THREADS> // 2;
my @files = Test-Files.documents;

enum Syntax (
    CodeDoc => 0,
    ForDoc  => 1,
    Doc     => 2
);

sub check-line($line, $state) {
    given $line {
        when /^\=begin\scode/ { CodeDoc                         }
        when /^\=for\scode/   { ForDoc                          }
        when /^\=end\scode/   { Doc                             }
        when /^\=\w+/         { Doc                             }
        when /^\s ** 4/       { CodeDoc                         }
        when /^.+$/           { $state !~~ Doc ?? $state !! Doc }
        default               { $state                          }
    }
}

my @promises = @files.map(-> $file {
    Promise.start({
        my Str        @contents;
        my Str        @lines = $file.IO.lines;
        my IO::Handle $fh    = $file.IO.open(:rw);
        my Syntax     $state = Doc;
        my Str        $buf;
        my Bool       $logged;
        for @lines -> $line {
            next if $line === Nil;

            $state = check-line($line, $state);
            if $state !~~ Doc {
                # Perl 5 or Perl 6 should keep regular spaces in code.
                @contents.push($line);
                next;
            }

            my $new-line = $line;
            if $new-line.chars < 6 {
                # Too short to contain Perl 5 or Perl 6.
                @contents.push($line);
                next;
            }

            $new-line ~~ s:g/Perl\x[0020](5||6)/Perl\x[00A0]$0/;
            if $new-line ne $line and ~$/ {
                $logged = True;
                @contents.push($new-line);
            } else {
                @contents.push($line);
            }
        }

        if $logged {
            say "Corrected mentions of Perl 6 to use NBSP in '$file'.";
            $logged = False;
        }

        $fh.spurt(@contents.join("\n"));
        $fh.close;
    })
});

@promises.race(:$degree).map(-> $p { await $p });

