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

    push @files, $file;
}

plan +@files;

for @files -> $file {
    ok !($file.IO.slurp ~~ / \t/), "no tabs in $file";
}

# vim: expandtab shiftwidth=4 ft=perl6
