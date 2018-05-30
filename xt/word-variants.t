#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Insure any text that mentions Perl uses a no-break space after it.

=end overview

my @files = Test-Files.pods;

my %variants = %(
                   "file handle" | "file-handle" => "filehandle",
                   "run-time" | "run time" => "runtime",
                   "short-hand" | "short hand" => "shorthand",
                   "look-ahead" => "lookahead",
                   "look-behind" | "look behind" => "lookbehind",
                   "smart-match" | "smart match" => "smartmatch",
                   "smart-matches" | "smart matches" => "smartmatches",
                   "smart-matching" | "smart matching" => "smartmatching",
                   "smart-matched" | "smart matched" => "smartmatched"
               );
plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    my @bad;
    for $file.IO.slurp.lines -> $line {
        $row++;
        next if $line ~~ / ^ \s+ /;
        for %variants.keys -> $rx {
            if $line ~~ m:g/ $rx / {
                $ok = False;
                @bad.push: "«$0» found in line $row. We prefer ｢%variants{$rx}｣";
            }
        }
    }
    my $result = $file;
    if !$ok {
        $result ~= " {@bad.join: ', '}): Certain words should be normalized. ";
    }
    ok $ok, "$result" ;
}

# vim: expandtab shiftwidth=4 ft=perl6
