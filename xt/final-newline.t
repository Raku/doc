#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Make sure that text files end in a newline

=end overview

my @files = Test-Files.files\
    .grep({$_ ne 'LICENSE'})\
    .grep({! $_.contains: 'custom-theme'})\
    .grep({! $_.contains: 'util/trigger-rebuild.txt'})\
    .grep({! $_.contains: 'jquery'})\
    .grep({! $_.ends-with: '.png'})\
    .grep({! $_.ends-with: '.svg'})\
    .grep({! $_.ends-with: '.ico'});

plan +@files;

for @files -> $file {
    ok $file.IO.slurp.substr(*-1) eq "\n", "$file must end in a newline";
}

# vim: expandtab shiftwidth=4 ft=perl6
