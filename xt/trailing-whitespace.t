#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

my @files = Test-Files.files\
    .grep({$_ ne 'LICENSE'|'Makefile'})\
    .grep({! $_.contains: 'custom-theme'})\
    .grep({! $_.contains: 'util/trigger-rebuild.txt'})\
    .grep({! $_.contains: 'jquery'})\
    .grep({! $_.ends-with: '.png'})\
    .grep({! $_.ends-with: '.svg'})\
    .grep({! $_.ends-with: '.ico'});

plan +@files;

for @files -> $file {
    my $ok = True;
    my $row = 0;
    for $file.IO.lines -> $line {
        ++$row;
        if $line ~~ / \s $/ {
           $ok = False; last;
        }
    }
    my $error = $file;
    $error ~= " (line $row)" if !$ok;
    ok $ok, "$error: Must not have any trailing whitespace.";
}

# vim: expandtab shiftwidth=4 ft=perl6
