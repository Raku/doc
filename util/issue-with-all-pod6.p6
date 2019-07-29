#!/usr/bin/env perl6

use v6;

my @docs = qx/git ls-files | grep "\.pod6"/.lines;

for @docs -> $d {
    my $repo-path =  S[doc] = '/perl6/doc/blob/master/doc' with $d;
    my $web-path =  S[doc] = 'https://docs.perl6.org' with $d;
    my $doc-name = $d.split("/")[*-1].split(".")[0];
    $web-path .= trans( [ "Language", "Type", "Programs", ".pod6" ] => 
                        [ "language", "type", "programs", ''] );
    say "* [ ] $doc-name [file]($repo-path), [generated]($web-path)";
}
