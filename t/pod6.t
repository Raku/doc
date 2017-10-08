use v6;
use Test;
use lib 'lib';

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(',').grep(*.IO.e);
    } else {
        @files= qx<git ls-files>.lines;
    }
}

plan +@files;

for @files -> $file {
    ok !($file ~~ / '.pod' $/), "no .pod files, only .pod6";
}

# vim: expandtab shiftwidth=4 ft=perl6
