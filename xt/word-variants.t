#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Make sure certain words are normalized by checking regular expressions.

=end overview

my @files = Test-Files.pods;

my %variants = %( filehandle => rx/file [\s+|\-] handle/,
                  filesystem => rx/file [\s+|\-] system/,
                  runtime => rx/run [\s+|\-] time/,
                  shorthand => rx/short [\s+|\-] hand/,
                  lookahead  => rx/look \- ahead/,
                  lookbehind => rx/look [\s+|\-] behind/,
                  smartmatch => rx/smart  [\s+|\-] match/,
                  zero-width => rx/zero \s+ width/
               );
plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    my @bad;
    my $content =  $file.IO.slurp.lines.join(" ");
    for %variants.kv -> $word, $rx {
        if $content ~~  $rx {
            $ok = False;
            @bad.push: "«$/» found. We prefer ｢$word｣";
        }
    }
    my $result = $file;
    if !$ok {
        $result ~= " {@bad.join: ', '}): Certain words should be normalized. ";
    }
    ok $ok, "$result" ;
}

# vim: expandtab shiftwidth=4 ft=perl6
