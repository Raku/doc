#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Check for duplicate words in documentation; ignore case.

Save the last word of each line, comparing it to the next line as well.

Allow a few well known duplicates, like 'long long'

=end overview

my $safe-dupes = Set.new(<method long default>); # Allow these dupes

my @files = Test-Files.files \
    .grep({$_.ends-with: '.pod6' or $_.ends-with: '.md'}) \
    .grep({$_ ne "doc/HomePage.pod6"}) \  # mostly HTML
    .grep({$_ ne "doc/404.pod6"});

plan +@files;

my $max-jobs = %*ENV<TEST_THREADS> // 2;
my %output;

sub test-promise($promise) {
    my $file = $promise.command[*-1];
    test-it(%output{$file}, $file);
}

my token word-min { <+alpha +digit +[']> };
my token word-max { <word-min> | <[$@%()-]> };
my token word-sep { <[,.;]> };

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

        $line.=subst(/<< 'http' <+alpha +digit +[:/.]>+ /,'RANDOMURL'); # ignore URLS

        # be slightly generous about what we consider a word
        #my @words = |$last-word, $line.comb: /(<word-max>+ <word-sep>?)/;
        my @words = |$last-word, $line.words.grep: *.chars;
        # but insure words have at least one letter.
        #@words = @words.grep(/<word-min>/);

        if $line.ends-with('.') {
            $last-word = '';
        } elsif @words {
            $last-word = @words[*-1];
        }

        my @line-dupes = @words.rotor(2=> -1).grep({$_[0] eq $_[1]}).map({$_[0]});
        for @line-dupes -> $dupe {
            next if $safe-dupes ∋ ~$dupe[0];
            @dupes.push: "“" ~ $dupe[0] ~ "” on line $line-num";
        }
    }
    my $message = "$file has duplicate words";
    is @dupes.join("\n"), '', $message;
}

my @jobs;
for @files -> $file {

    my $output = '';

    if $file ~~ / '.pod6' $/ {
        my $a = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
        %output{$file} = '';
        $a.stdout.tap(-> $buf { %output{$file} = %output{$file} ~ $buf });
        push @jobs: $a.start;
        if +@jobs > $max-jobs {
            test-promise(await @jobs.shift)
        }
    } else {
        test-it($file.IO.slurp, $file);
    }
}

for @jobs.map: {await $_} -> $r { test-promise($r) }

# vim: expandtab shiftwidth=4 ft=perl6
