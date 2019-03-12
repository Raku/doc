#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Pod::Cache;
use Test-Files;

=begin overview

Enforce B<curly braces> and B<square> or B<angle> B<brackets>.

=end overview

my @files = Test-Files.documents;

plan +@files;

sub test-it(Str $output, Str $file) {
    my $ok = True;

    my $msg;

    my $line = $output.subst(/\s+/, ' ', :g)                         # canonicalize whitespace
                      .subst('Opening bracket is required for', ''); # rakudo/rakudo#2672

    if $line ~~ /:i <!after curly> ' ' 'braces' >> / {
        $msg ~= "Found 'braces' without 'curly'. ";
        $ok = False;
    }

    if $line ~~ /:i <!after square><!after angle><!after lenticular> ' ' ('bracket' [s|ed]?) >> / {
        $msg ~= "Found '{~$0}' without 'square' or 'angle'.";
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
