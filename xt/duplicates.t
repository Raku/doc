#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Pod::Cache;
use Test-Files;

=begin overview

Check for duplicate words in documentation; ignore case.

Save the last word of each line, comparing it to the next line as well.

Allow a few well known duplicates, like 'long long'

=end overview

my $safe-dupes = Set.new(<method long default that yada,>); # Allow these dupes

my @files = Test-Files.documents \
    .grep({$_ ne "doc/HomePage.pod6"}) \  # mostly HTML
    .grep({$_ ne "doc/404.pod6"});

plan +@files;

sub test-it(Str $output, Str $file) {
    my $ok = True;

    my @dupes;
    my $last-word = '';
    my $line-num = 0;
    for $output.lines -> $line is copy {
        $line-num++;
        if $line.starts-with: ' ' {
            # could be code, table, heading; don't check for dupes
            $last-word = '';
            next;
        }
        next unless $line.chars;

        my @words = |$last-word, $line.words.grep: *.chars;

        if $line.ends-with('.') {
            $last-word = '';
        } elsif @words {
            $last-word = @words[*-1];
        }

        my @line-dupes = @words.rotor(2=> -1).grep({$_[0] eq $_[1]}).map({$_[0]});
        for @line-dupes -> $dupe {
            # explicitly allowed duplicates
            next if $safe-dupes ∋ ~$dupe[0];
            # Single characters that are probably fine
            next if $dupe ~~ /^ [<:Sm>|<:CS>] $/;
            @dupes.push: "“" ~ $dupe[0] ~ "” on line $line-num";
        }
    }
    my $message = "$file has duplicate words";
    is @dupes.join("\n"), '', $message;
}

for @files -> $file {
    if $file.ends-with('.pod6') {
        test-it(Pod::Cache.cache-file($file).IO.slurp, $file)
    } else {
        test-it($file.IO.slurp, $file);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
