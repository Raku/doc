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
        @files = qx<git ls-files>.lines;
    }
}

@files = @files.grep({$_ ne 'LICENSE'|'Makefile'})\
               .grep({! $_.contains('custom-theme')})\
               .grep({! $_.contains('util/trigger-rebuild.txt')})\
               .grep({! $_.contains('jquery')})\
               .grep({! $_.ends-with('.png')})\
               .grep({! $_.ends-with('.ico')});

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
