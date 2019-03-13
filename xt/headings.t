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
        if $line.starts-with("=TITLE ") or $line.starts-with("=SUBTITLE ") {
            # ignore first word like "=TITLE"
            my $title = $line.substr($line.index(' ') + 1);
            # ignore "class X::TypeCheck" and the like
            $title ~~ s:g/^ ( class | role | module |enum ) \s+ \S+//;
            # proper names, macros, acronyms, and other exceptions
            $title ~~ s:g/ <|w> (
                I
                | Perl 6 | Pod 6 | P6 | C3 | NQP
                | AST | EVAL | PRE | POST | CLI | MOP
                | TITLE | SUBTITLE | "MONKEY-TYPING"
                | API | TCP | UDP | FAQ
                | JavaScript | Node | Haskell | Python | Ruby | C | Node.js
                | "Input/Output" | "I/O"
                | "Alice in Wonderland"
                | "Virtual Machine"
                | "Binary Large OBject"
                | Unicode | ASCII
                | "Normal Form " ( "C" | "D" | "KC" | "KD" )
                | POSIX | QNX | Windows | Cygwin | Win32
                # class names
                | Whatever
                | ( <:Lu><:L>+ "::" )+ <:Lu><:L>+
                # these seem fishy?
                | Socket
            ) <|w> //;
            $title ~~ s:g/ <|w> <[ C ]> \< .*? \> //;
            # ignore known classes like "Real" and "Date" which are capitalized
            my @words = $title ~~ m:g/ <|w> ( <:Lu> \S+ ) /;
            for @words -> $word {
                # if it exists, skip it
                try {
                    ::($word);
                    $title ~~ s:g/ << $word >> //;
                }
            }
            # sentence case: all lowercase, titlecase for first
            # character except for cases where the first word is a
            # uncapitalized name of a program
            if $title !~~ $title.lc.tc and $title !~~ /^ p6doc / {
                @lines.push($line-no);
                @examples.push($line);
            }
        }
    }
    if @lines {
        flunk "$file has inconsistent capitalised headings on lines: {@lines}\n"
        ~ @examples.join("\n");
    } else {
        pass "$file capitalises headings consistently ";
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
