#!/usr/bin/env raku

=begin comment

This script clones the website repository (or updates the clone if it already exists)
and then runs the xtest suite against those rakudoc files.

To create a PR for doc-website, one will have to create a branch in the checkout
manually and push manually once the tests pass.

=end comment

my $dir = "doc-website".IO;

if $dir.d {
   run(<git pull --rebase>, :cwd($dir));    
} else {
    run(<git clone git@github.com:Raku/doc-website.git>);
}

my @files = $dir.child('Website').child('structure-sources').IO.dir;
%*ENV<TEST_FILES>=@files.join(' ');

run(<make xtest>);
