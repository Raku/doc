use v6;
use Test;
use lib 'lib';

for qx<git ls-files>.lines -> $file is copy {
    next if $file eq "LICENSE"|"Makefile";
    next if $file ~~ / 'custom-theme'/;
    next if $file ~~ / 'jquery'/;
    next if $file ~~ / '.png' $/;
    next if $file ~~ / '.ico' $/;
  
    ok !($file.IO.slurp ~~ / \t/), "no tabs in $file";
}

# vim: expandtab shiftwidth=4 ft=perl6
