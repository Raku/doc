#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test-Files;

my @files = Test-Files.files;

my @pod-only-files = @files.grep({$_.ends-with: '.pod'}) ;

plan 1;
is @pod-only-files.elems, 0, "no .pod files, only .pod6" ;


# vim: expandtab shiftwidth=4 ft=perl6
