use v6;
use Test;
use lib 'lib';

my @files;

for qx<git ls-files>.lines -> $file {
    next if $file eq "LICENSE"|"Makefile";
    next if $file ~~ / 'custom-theme'/;
    next if $file ~~ / 'jquery'/;
    next if $file ~~ / '.png' $/;
    next if $file ~~ / '.ico' $/;
    next if $file ~~ / 'util/trigger-rebuild.txt' /;

    push @files, $file;
}

plan +@files;

for @files -> $file {
    my $ok = True;
    my $row = 0;
    for $file.IO.lines -> $line {
        ++$row;
        if $line ~~ / \s $/ {
           $ok = False; last;
        }
    }
    my $error = $file;
    $error ~= " (line $row)" if !$ok;
    ok $ok, "$error: Must not have any trailing whitespace.";
}

# vim: expandtab shiftwidth=4 ft=perl6
