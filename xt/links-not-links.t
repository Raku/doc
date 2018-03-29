#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;
use Pod::To::HTML;
use MONKEY-SEE-NO-EVAL;   

# Every .pod6 file in the Type directory.
my @files = Test-Files.files.grep({$_.ends-with: '.pod6'}).grep(* ~~ /Type | Language/);

plan +@files;

for @files -> $file {
    my @lines;
    my Int $line-no = 1;
    my @links = $file.IO.lines.grep( * ~~ / https?\: /);
    my @links-not-links;
    for @links -> $link {
        my $pod=qq:to/END/;
=pod
$link
=pod
END

        my @number-of-links = ( $link ~~ m:g{ https?\: } );
        my $html = pod2html(EVAL($pod~ "\n\$=pod"));
        my @number-of-hrefs = ( $html ~~ m:g{a\s+href\= } );
        push @links-not-links, $link if +@number-of-links > +@number-of-hrefs;
    }
    if @links-not-links {
        flunk "$file uses non-linked links « {@links-not-links} »";
    } else {
        pass "$file return types are ok";
    }
}
