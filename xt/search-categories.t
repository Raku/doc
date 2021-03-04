#!/usr/bin/env raku

use Test;
use File::Temp;

use lib $*PROGRAM.parent(2).child('lib');
use Pod::Convenience;
use Test-Files;

=begin SYNOPSIS



=end SYNOPSIS

constant @categories = 'Types', 'Modules', 'Subroutines',
                       'Methods', 'Terms',
                       'Adverbs', 'Traits', 'Phasers', 'Asynchronous Phasers',
                       'Syntax', 'Regexes', 'Control flow',
                       'Pragmas',
                       'Variables', 'Reference', 'Language',
                       'Operators',
                       'Listop operators', 'Infix operators',
                       'Metaoperators', 'Postfix operators', 'Prefix operators',
                       'Circumfix operators', 'Postcircumfix operators',
                       'Programs', 'Foreign', 'Tutorial';

plan +my @files = Test-Files.pods.grep({ not $_.contains('about')});

for @files -> $file {
    subtest $file => {
        my @examples = refs($file);
        test-ref $_ for @examples;
    }
}

sub test-ref ($ref) {
    my $contents = $ref<contents>.cache;
    for $contents<> -> $item {
        is $item.elems, 2, "Correct dimension for a search anchor '$contents.Str()' $ref<file>";
        ok $item[0] (elem) @categories, 'It has correct category';
    }
}

sub refs (IO() $file) {
    my @chunks = extract-pod($file).contents;
    gather while @chunks {
        my $chunk = @chunks.pop;
        if $chunk ~~ Pod::FormattingCode && $chunk.type eq 'X' {
            take %( contents => $chunk.meta.flat, :$file );
        }
        else {
            @chunks.push(|$chunk.contents) if $chunk.^can('contents');
        }
    }
}

sub walk ($arg) {
    given $arg {
        when Pod::FormattingCode { walk $arg.contents }
        when Str   { $arg }
        when Array { $arg.map({walk $_}).join }
    }
}
