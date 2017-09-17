use v6;
use Test;

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    for qx<git ls-files>.lines -> $file {
        next unless $file ~~ / '.pod6' $/;
        push @files, $file;
    }
}

plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    for $file.IO.slurp.lines -> $line {
        $row++;
        if $line ~~ / ^ \s+ / {
            next;
        }
        for $line ~~ m:g/ <!after 'implementing '> 'Perl' $<space>=(\s+) \d / -> $match {
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
