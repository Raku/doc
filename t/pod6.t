#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(' ').grep(*.IO.e);
    } else {
        @files= qx<git ls-files>.lines;
    }
}

my @pod-only-files = @files.grep( {/ '.pod' $/} ) ;
plan 1;
is @pod-only-files.elems, 0, "no .pod files, only .pod6" ;


# vim: expandtab shiftwidth=4 ft=perl6
