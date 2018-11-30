#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;
use Test-Files;

my @files = Test-Files.documents;

plan +@files;

# these words don't have to be capitalized
# my $stopwords = /^()$/;

for @files -> $file {
    my @lines;
    my @examples;
    my $line-no = 0;
    for $file.IO.lines -> $line {
        $line-no++;
        if $line.starts-with("=TITLE") or $line.starts-with("=SUBTITLE") {
            # ignore first word like "=TITLE"
            my $title = $line.substr($line.index(' ') + 1);
            # ignore "class X::TypeCheck" and the like
            $title ~~ s:g/^ ( class | role | module ) \s+ \S+//;
            $title ~~ s:g/ <|w> ( Perl 6 | AST | EVAL | PRE | POST | Whatever ) //;
            $title ~~ s:g/ <|w> <[ C ]> \< .*? \> //;
            # ignore known classes like "Real" which are capitalized
            my @words = $title ~~ m:g/ <|w> ( <:Lu> \S+ ) /;
            for @words -> $word {
                # if it exists, skip it
                try {
                    ::($word);
                    $title ~~ s:g/ << $word >> //;
                }
            }
            # sentence case: all lowercase, titlecase for first character
            if $title !~~ $title.lc.tc {
                @lines.push($line-no);
                @examples.push($title);
            }
        }
    }
    if @lines {
        flunk "$file has inconsisten capitalised headings on lines: {@lines}\n"
        ~ @examples.join("\n");
    } else {
        pass "$file capitalises headings consistently ";
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
