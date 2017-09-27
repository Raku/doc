use v6;
use Test;
use lib 'lib';

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(',');
    } else {
        for qx<git ls-files>.lines -> $file {
            next if $file eq "LICENSE"|"Makefile";
            next if $file ~~ / 'custom-theme'/;
            next if $file ~~ / 'jquery'/;
            next if $file ~~ / '.png' $/;
            next if $file ~~ / '.ico' $/;
        
            push @files, $file;
        }
    }
}

plan +@files;

for @files -> $file {
    my @lines;
    my $line-no = 1;
    for $file.IO.lines -> $line {
        @lines.push($line-no) if $line.contains("\t");
        $line-no++;
    }
    if @lines {
        flunk "$file has tabs on lines: {@lines}";
    } else {
        pass "$file has no tabs";
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
