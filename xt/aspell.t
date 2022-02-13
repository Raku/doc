#!/usr/bin/env raku

use Test;

use lib $*PROGRAM.parent(2).child('lib');
use Pod::Cache;
use Test-Files;

=begin overview

Spell check all the pod and most markdown files in the documentation directory.

Ignore case, and provide a repo-specific list of approved words,
which include technical jargon, method and class names, etc.

To run this test, you'll need to install aspell and the English dictionary package.

On Mac OS X, you can install aspell using macports (https://macports.org/).

=begin code
$ sudo port install aspell
$ sudo port install aspell-dict-en
=end code

On Linux, both aspell and the C<en> dictionary should be available in your
distribution's package manager and may already be installed.  However, depending
on your distribution, you may need to update to aspell's C<en> dictionary to a
more recent version than the one available through your package manager. (The
2019.10.06 version is known to work).  You can download up-to-date dictionary
files directly from aspell at
L<https://ftp.gnu.org/gnu/aspell/dict/0index.html>; the downloaded archive will
include installation instructions.

This test uses separate lexicons for descriptive text and code, allowing us to
specify "words" that are only allowed in code (variable names, some output,
etc.).

If the test fails, you can make it pass again by changing the
text (fixing the spelling issue), or adding the new word to
C<xt/pws/words.pws> (if it's a word, a class/method name, known
program name, etc.), or to C<xt/pws/code.pws> (if it's a fragment of
text that is part of a code example)

=end overview

my @files = Test-Files.documents.grep({not $_ ~~ / 'README.' .. '.md' /});

plan +@files * 2;

my $proc = shell('aspell -v');
if $proc.exitcode {
    skip-rest "This test requires aspell";
    exit;
}

# generate a combined words file
# a header is required, but is supplied by words.pws

my $dict = $*PROGRAM.parent.child("pws/aspell.pws").open(:w);
$dict.say($*PROGRAM.parent.child("pws/words.pws").IO.slurp.chomp);
$dict.say($*PROGRAM.parent.child("pws/code.pws").IO.slurp.chomp);
$dict.close;

my %output;

my $lock = Lock.new;

@files.race.map: -> $file {
    # We use either the raw markdown or the rendered/cached Pod.
    my $input-file = $file.ends-with('.pod6') && !$file.contains('pod-cache') ?? Pod::Cache.cache-file($file) !! $file;

    # split the input file into a block of code and a block of text
    # anything with a leading space is considered code, and we just
    # concat all the code and text into one block of each per file

    my Str $code = '';
    my Str $text = '';

    # Process the text so that aspell understands it.
    # Every line starts with a ^
    # turn \n and \t into spaces to avoid \nFoo being read as "nFoo" by aspell
    for $input-file.IO.slurp.lines -> $line {
        my Bool $is-code = $line.starts-with(' ');

        my $processed =  '^' ~ $line.subst(/ \S <( '\\' <[tn]> )>/ , ' ', :g) ~ "\n";

        $code ~= $processed if $is-code;
        $text ~= $processed unless $is-code;
    }

    for <code text> -> $type {
        # Restrict dictionary used based on block type
        my ($dict, $body);
        if $type eq "code" {
            $body = $code;
            $dict = $*PROGRAM.parent.child("pws/aspell.pws").absolute;
        } else {
            $body = $text;
            $dict = $*PROGRAM.parent.child("pws/words.pws").absolute;
        }

        react {
            my $proc = Proc::Async.new:
                :w,
                ['aspell', '-a', '-l', 'en_US', '--dont-suggest',
                 '--ignore-case', "--extra-dicts=$dict", '--mode=url'];

            whenever $proc.stdout.lines {
                $lock.protect: {
                    %output{$file}{$type}<output> ~= "$_\n";
                }
            }

            whenever $proc.start {
                done;
            }

            whenever $proc.print: "!\n$body\n" {
                $proc.close-stdin;
            }
        }
    }
}

for %output.keys.sort -> $file {
    for %output{$file}.keys -> $type {
        my $spelling-errors =
            %output{$file}{$type}<output>.lines.tail(*-1).map: -> $line {
                $line ?? $line.words[1] !! Empty
            }

        nok $spelling-errors, "$file ($type) has {+$spelling-errors} spelling errors";
        if $spelling-errors -> $_  {
            diag join("\n", 'Errors:', '='x 7, |$_).indent: 4 }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
