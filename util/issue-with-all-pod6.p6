#!/usr/bin/env perl6

use v6;

my @docs = qx/git ls-files | grep "\.pod6"/.lines;

for @docs -> $d {
    my $repo-path =  S[doc] = '/perl6/doc/blob/master/doc' with $d;
    my $web-path =  S[doc] = 'https://docs.perl6.org' with $d;
    my $doc-name = $d.split("/")[*-1].split(".")[0];
    if $web-path ~~ /Type/ {
        my @fragments = $web-path.split("/Type/");
        $doc-name = @fragments[1].trans( ['/'] => ['::'] ).split(".")[0];
        $web-path = @fragments[0] ~ "/type/" ~ $doc-name;
    }
    $web-path .= trans( [ "Language",  "Programs" ] =>
                        [ "language",  "programs" ] );
    say "* [ ] $doc-name [file]($repo-path), [generated]($web-path)";
}
