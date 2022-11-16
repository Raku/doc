#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Make sure no files include the vim mode line.

This was historically useful but is now considered harmful.

https://github.com/Raku/doc/issues/3058

=end overview

my @files = Test-Files.files\
    .grep({! $_.ends-with: '.png' | '.ico'});

if @files {
    plan +@files;
} else {
    plan :skip-all<No relevant files specified>;
}

for @files -> $file {
    nok $file.IO.slurp ~~ /^^ '# vim: '/, "$file must not contain vim mode line";
}
