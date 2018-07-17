#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Make sure certain words are normalized by checking regular expressions.

=end overview

my @files = Test-Files.pods;

my %variants = %( filehandle => 'file [\s+|\-] handle',
                  filesystem => 'file [\s+|\-] system',
                  runtime    => 'run [\s+|\-] time',
                  shorthand  => 'short [\s+|\-] hand',
                  lookahead  => 'look \- ahead',
                  lookbehind => 'look [\s+|\-] behind',
                  smartmatch => 'smart  [\s+|\-] match',
                  zero-width => 'zero \s+ width<!before \' joiner\'>',
                  NYI        => 'niy',
                  metaoperator => 'meta [\s+|\-] operator',
               );
plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    my @bad;
    my $content =  $file.IO.slurp.lines.join(" ");
    for %variants.kv -> $word, $rx {
        if $content ~~ m/:i << <{$rx}> / {
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
