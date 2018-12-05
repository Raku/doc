#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Ensure any text that mentions Perl uses a no-break space after it.

=end overview

my @files = Test-Files.documents;

plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    my @bad;
    my $content = $file.IO.slurp.lines.join("\n");
    for $content ~~ m:g/ <!after 'implementing '> 'Perl' $<space>=(\s+) \d / -> $match {
        my $spaces = ~$match<space>;
        if $spaces.chars != 1 || $spaces.uniname ne "NO-BREAK SPACE" {
            $ok = False;
            @bad.push: $row;
        }
    }
    my $error = $file;
    if !$ok {
        $error ~= " (line{@bad>1 ?? "s" !! ""} {@bad.join: ', '})";
    }
    ok $ok, "$error: Perl followed by a version should have a single non-breaking space." ;
}

# vim: expandtab shiftwidth=4 ft=perl6
