#!/usr/bin/env raku

my $dir = "doc-website".IO;

if $dir.d {
   run(<git pull --rebase>, :cwd($dir));
} else {
    run(<git clone git@github.com:Raku/doc-website.git>);
}

my @files = $dir.child('Website').child('structure-sources').IO.dir;
%*ENV<TEST_FILES>=@files.join(' ');

run(<make xtest>);
