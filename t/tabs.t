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
               .grep({! $_.contains('jquery')})\
               .grep({! $_.ends-with('.png')})\
               .grep({! $_.ends-with('.ico')});

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
