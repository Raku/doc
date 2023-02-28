#!/usr/bin/env raku

=begin overview

Avoid I<bare> URLs that are not links; URLs should go inside C<L<>> clauses,
even if they have no text to link to.

=end overview

use Test;
use lib $*PROGRAM.parent(2).child('lib');

use Test-Files;
use Pod::Convenience;

my @files = Test-Files.pods\
    .grep(* ne "doc/404.pod6")\
    .grep(* ne "doc/HomePage.pod6");

plan +@files;

sub walk-content($x) {
    next if $x ~~ Pod::Block::Code;    # Code blocks OK
    next if $x ~~ Pod::Block::Comment; # Comments not user-facing
    next if $x ~~ Pod::Block::Table;   # ... code-ish
    try next if $x.type eq 'L';        # L<> is where the links are supposed to be!
    for $x.contents -> $contents {
        next unless $contents;
        for @$contents -> $item {
            if $item ~~ Str {
                if $item ~~ / $<url>=[ 'http' 's'? '://' <-[/]>* '/'? ] /  {
                    flunk "[$x.type] $/<url>";
                }
            } else {
                walk-content($item);
            }
        }
    }
}

for @files -> $file {
    my @chunks = extract-pod($file).contents;

    # This emits flunks for any non-safe URLS found.
    # a test with no passing or failing subtests is a pass.
    subtest $file => {
        walk-content($_) for @chunks;
    }
}
