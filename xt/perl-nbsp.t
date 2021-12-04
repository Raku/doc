#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Ensure any text that mentions Perl uses a no-break space after it.

=end overview

my @files = Test-Files.documents;

plan +@files;

for @files.sort -> $file {
    my $err-count = 0;
    my $content = $file.IO.slurp;
    for $content ~~ m:g/ <!after 'implementing '> 'Perl' $<space>=(\s+) \d / -> $match {
        my $spaces = ~$match<space>;
        if $spaces.chars != 1 || $spaces.uniname ne "NO-BREAK SPACE" {
            $err-count++;
        }
    }
    my $error = $file;
    if $err-count {
        $error ~= " ($err-count instance{$err-count==1 ?? '' !! 's'})";
    }
    ok !$err-count, "$error: Perl followed by a version should have a single non-breaking space." ;
}

# vim: expandtab shiftwidth=4 ft=perl6
