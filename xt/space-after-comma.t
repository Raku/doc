#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Pod::Cache;
use Test-Files;

=begin overview

Ensure any text that isn't a code example has a space after each comma.

=end overview

my @files = Test-Files.documents\
    .grep({not $_ ~~ / 'README.' .. '.md' /});

plan +@files;

sub test-it(Str $output, Str $file) {
    my $ok = True;

    my $msg = '';
    for $output.lines -> $line-orig {
        next if $line-orig ~~ / ^ '    '/;
        my $line = $line-orig;

        # ignore these cases already in docs/ that don't strictly follow rule
        $line ~~ s:g/ "','" //;
        $line ~~ s:g/ '","' //;
        $line ~~ s:g/ << 'a,a,a' >> //;
        $line ~~ s:g/ << 'a,a,.' //;
        $line ~~ s:g/ << 'a,a' >> //;
        $line ~~ s:g/ << 'a,' //;
        $line ~~ s:g/ ',a' >> //;
        $line ~~ s:g/ '{AM,PM}' //;
        $line ~~ s:g/ '(SELF,)' //;
        $line ~~ s:g/ '"1,2"' //;
        $line ~~ s:g/ '"a,b"' //;
        $line ~~ s:g/ '($var,)' //;
        $line ~~ s:g/ '(3,)' //;
        $line ~~ s:g/ << 'thing,category' >> //;
        $line ~~ s:g/ 'postfix ,=' //;

        if $line ~~ / ',' [ <!before ' '> & <!before $> ] / {
            $msg ~= "Must have space after comma on line `$line`\n";
            diag "Failure on line `$line`";
            $ok = False;
        }

        if $line-orig ~~ / <alpha> '..' (<space> | $) / {
            $msg ~= "File contains .. in `$line-orig`\n";
            diag "Failure on line `$line`";
            $ok = False;
        }
    }
    my $error = $file;
    ok $ok, $error ~ ($msg ?? ": $msg" !! "");
}

for @files -> $file {
    if $file.ends-with('.pod6') {
        test-it(Pod::Cache.cache-file($file).IO.slurp, $file);
    } else {
        test-it($file.IO.slurp, $file);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
