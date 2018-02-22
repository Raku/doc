#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

my @files = Test-Files.files;

my @pod-only-files = @files.grep({$_.ends-with: '.pod'}) ;

plan 1;
is @pod-only-files.elems, 0, "no .pod files, only .pod6" ;


# vim: expandtab shiftwidth=4 ft=perl6
