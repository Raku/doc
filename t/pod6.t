use v6;
use Test;
use lib 'lib';

my @files = qx<git ls-files>.lines;

plan +@files;

for @files -> $file {
    ok !($file ~~ / '.pod' $/), "no .pod files, only .pod6";
}

# vim: expandtab shiftwidth=4 ft=perl6
