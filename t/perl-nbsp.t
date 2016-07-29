use v6;
use Test;

my @files = qqx<git ls-files doc>.lines;

plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    for $file.IO.slurp.lines -> $line {
        $row++;
        if $line ~~ / ^ \s+ / {
            next;
        }
        for $line ~~ m:g/ 'Perl' $<space>=(\s+) \d / -> $match {
            my $spaces = ~$match<space>;
            if $spaces.chars != 1 || $spaces.uniname ne "NO-BREAK SPACE" {
                $ok = False; last;
            }
        }
    }
    my $error = $file;
    if !$ok {
        $error ~= " (line $row)";
    }
    ok $ok, "$error: Perl followed by a version should have a single non-breaking space." ;
}

# vim: expandtab shiftwidth=4 ft=perl6
