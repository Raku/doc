#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Pod::Cache;
use Test-Files;

=begin overview

Spell check all the pod and most markdown files in the documentation directory.

Ignore case, and provide a repo-specific list of approved words,
which include technical jargon, method and class names, etc.

If the test fails, you can make it pass again by changing the
text (fixing the spelling issue), or adding the new word to
C<xt/words.pws> (if it's a word, a class/method name, known
program name, etc.), or to C<xt/code.pws> (if it's a fragment of
text that is part of a code example)

=end overview

my @files = Test-Files.documents.grep({not $_ ~~ / 'README.' .. '.md' /});

plan +@files;

my $proc = shell('aspell -v');
if $proc.exitcode {
    skip-rest "This test requires aspell";
    exit;
}

# generate a combined words file
my $dict = open "xt/aspell.pws", :w;
$dict.say('personal_ws-1.1 en 0 utf-8');
$dict.say("xt/words.pws".IO.slurp.chomp);
$dict.say("xt/code.pws".IO.slurp.chomp);
$dict.close;

my %output;

sub test-it($promises, $file) {
    await Promise.allof: |$promises;
    my $tasks = $promises».result;

    my $count;
    for %output{$file}.lines -> $line {
        FIRST next; # dump first line
        next if $line eq '';
        diag $line;
        $count++;
    }

    my $so-many  = $count // "no";
    ok !$count, "$file has $so-many spelling errors";
}

for @files -> $file {
    my $input-file = $file.ends-with('.pod6') ?? Pod::Cache.cache-file($file) !! $file;

    my $fixer = Proc::Async.new(«perl -pne ｢BEGIN {print "!\n"} s/\S\K\\[tn]/ /g; s/^/^/｣ $input-file»);
    my $proc = Proc::Async.new(<aspell -a -l en_US --ignore-case --extra-dicts=./xt/aspell.pws --mode=url>);
    $proc.bind-stdin: $fixer.stdout: :bin;
    %output{$file}="";
    $proc.stdout.tap(-> $buf { %output{$file} = %output{$file} ~ $buf });
    $proc.stderr.tap(-> $buf {});
    test-it([$fixer.start, $proc.start], $file);
}

# vim: expandtab shiftwidth=4 ft=perl6
