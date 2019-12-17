#!/usr/bin/env raku

# xt/aspell.t dies if you try to run too many tests. Run only a few at a time.
# TODO: run them all inside a prove harness?

use lib 'lib';
use Test-Files;

my @files = Test-Files.documents.grep({not $_ ~~ / 'README.' .. '.md' /});

# Only process this many at a time.
my $at-a-time=20;

for @files.rotor($at-a-time) -> $files {
    my $a = Proc::Async.new('xt/aspell.t', |$files);
    $a.stdout.tap(-> $buf { $buf.print });
    await $a.start;
}




