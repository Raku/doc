#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;
use Test-Files;

my @files = Test-Files.files\
    .grep({$_ ne 'LICENSE'|'Makefile'})\
    .grep({! $_.contains('custom-theme')})\
    .grep({! $_.contains('jquery')})\
    .grep({! $_.ends-with('.png')})\
    .grep({! $_.ends-with('.svg')})\
    .grep({! $_.ends-with('.ico')});

plan +@files;

for @files -> $file {
    my @lines;
    my $line-no = 1;
    for $file.IO.lines -> $line {
        @lines.push($line-no) if $line.contains("\t");
        $line-no++;
    }
    if @lines {
        flunk "$file has tabs on lines: {@lines}";
    } else {
        pass "$file has no tabs";
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
