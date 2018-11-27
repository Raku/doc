#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Pod::Cache;
use Test-Files;

=begin overview

Enforce B<curly braces> and B<square brackets>.

=end overview

my @files = Test-Files.documents;

plan +@files;

sub test-it(Str $output, Str $file) {
    my $ok = True;

    my $msg;

    if $output ~~ /:i <!after curly> ' braces' / {
        $msg ~= "Found 'braces' without 'curly'. "; 
        $ok = False;
    }

    if $output ~~ /:i <!after square> ' brackets' / {
        $msg ~= "Found 'brackets' without 'square' "; 
        $ok = False;
    }
 
    ok $ok, $file ~ ($msg ?? ": $msg" !! "");
}

for @files -> $file {
    if $file.ends-with('.pod6') {
        test-it(Pod::Cache.cache-file($file).IO.slurp, $file);
    } else {
        test-it($file.IO.slurp, $file);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
