use v6;
use Test;
use lib 'lib';

my @files;

# Every .pod6 file in the Type directory.
@files = qx<git ls-files>.lines.grep(* ~~ /'.pod6'/).grep(* ~~ /Type | Language/);

plan +@files;

for @files -> $file {
    my @lines;
    my Int $line-no = 1;
    for $file.IO.lines -> $line {
        if so $line ~~ /(multi|method|sub) .+? ')' \s+? 'returns' \s+? (<alnum>|':')+? $/ {
            @lines.push($line-no);
        }
        $line-no++;
    }
    if @lines {
        flunk "$file uses 'returns' at lines: {@lines}; should be -->";
    } else {
        pass "$file return types are ok";
    }
}
