#!/usr/bin/env perl6

use Test;

use lib 'lib';
use Pod::Convenience;
use Test-Files;

=begin SYNOPSIS

Search through all code blocks (with C«:lang<perl6>» or unset C«:lang»)
in the document files for lines beginning with "m:" which are likely
copy-pasted from an IRC log where Camelia or evalable was involved.

"m:" can also be part of an adverb'd C«m///». We try to avoid such false
positives heuristically by looking for match adverbs afterwards.

What we can't distinguish are labels called "m".

=end SYNOPSIS

my @files = Test-Files.pods;

sub walk($arg) {
    given $arg {
        when Pod::FormattingCode { walk $arg.contents }
        when Str   { $arg }
        when Array { $arg.map({walk $_}).join }
    }
}

# Extract all the examples from the given files
my @examples;

my $counts = BagHash.new;
for @files -> $file {
    my @chunks = extract-pod($file.IO).contents;
    while @chunks {
        my $chunk = @chunks.pop;
        if $chunk ~~ Pod::Block::Code {
            # Only test :lang<perl6> (which is the default)
            next unless quietly $chunk.config<lang> eq '' | 'perl6';
            @examples.push: %(
                'contents',  $chunk.contents.map({walk $_}).join,
                'file',      $file,
                'count',     ++$counts{$file},
            );
        } else {
            if $chunk.^can('contents') {
                @chunks.push(|$chunk.contents)
            }
        }
    }
}

plan +@examples;

my regex match-adverbs {
    | 'i'  | 'ignorecase'
    | 'm'  | 'ignoremark'
    | 'r'  | 'ratchet'
    | 's'  | 'sigspace'
    | 'P5' | 'Perl5'
    | \d*  [ 'st' || 'nd' || 'rd' || 'nth' ]
    | \d*  [ 'c'  |  'continue' ]
    | 'ex' | 'exhaustive'
    | 'g'  | 'global'
    | \d*  [ 'p'  |  'pos' ]
    | 'ov' | 'overlap'
}

for @examples -> $eg {
    my @camelias = $eg<contents>.lines».trim.grep: /
        ^ 'm:' <.ws> <!before <match-adverbs> » >
    /;

    nok @camelias, "$eg<file> chunk $eg<count> does not invoke camelia";
    diag $_ for @camelias;
}
