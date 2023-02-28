#!/usr/bin/env raku

my @docs = qx/git ls-files | grep "\.rakudoc"/.lines;

for @docs -> $d {
    my $repo-path =  S[doc] = '/raku/doc/blob/master/doc' with $d;
    my $web-path =  S[doc] = 'https://docs.perl6.org' with $d;
    my $doc-name = $d.split("/")[*-1].split(".")[0];
    given $web-path {
        when /Type/ {
            my @fragments = $web-path.split("/Type/");
            $doc-name = @fragments[1].trans( ['/'] => ['::'] ).split(".")[0];
            $web-path = @fragments[0] ~ "/type/" ~ $doc-name;
        }
    }

    $web-path .= trans( [ "Language",  "Programs", ".rakudoc" ] =>
                        [ "language",  "programs", "" ] );
    say "* [ ] $doc-name [file]($repo-path), [generated]($web-path)";
}
