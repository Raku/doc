#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Pod::Cache;
use Test-Files;

=begin overview

Avoid using C<..> - usually a typo for C<.> or C<...>

=end overview

my @files = Test-Files.documents;

plan +@files;

sub test-it(Str $output, Str $file) {
    my $ok = True;

    for $output.lines -> $line {
        if $line ~~ / <alpha> '..' (<space> | $) / {
            diag "Failure on line `$line`";
            $ok = False;
        }
    }
    my $error = $file;
    ok $ok, "$error: file contains ..";
}

for @files -> $file {
    if $file.ends-with('.pod6') {
        test-it(Pod::Cache.cache-file($file).IO.slurp, $file)
    } else {
        test-it($file.IO.slurp, $file);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
