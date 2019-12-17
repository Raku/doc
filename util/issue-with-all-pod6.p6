#!/usr/bin/env raku

use v6;

my @docs = qx/git ls-files | grep "\.pod6"/.lines;

for @docs -> $d {
    my $repo-path =  S[doc] = '/raku/doc/blob/master/doc' with $d;
    my $web-path =  S[doc] = 'https://docs.raku.org' with $d;
    my $doc-name = $d.split("/")[*-1].split(".")[0];
    given $web-path {
        when /Type/ {
            my @fragments = $web-path.split("/Type/");
            $doc-name = @fragments[1].trans( ['/'] => ['::'] ).split(".")[0];
            $web-path = @fragments[0] ~ "/type/" ~ $doc-name;
        }
        when "https://docs.raku.org/HomePage.pod6" {
            $web-path = "https://docs.raku.org/"
        }
    }

    $web-path .= trans( [ "Language",  "Programs", ".pod6" ] =>
                        [ "language",  "programs", "" ] );
    say "* [ ] $doc-name [file]($repo-path), [generated]($web-path)";
}
