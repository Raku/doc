#!/usr/bin/env raku

use Test;
use File::Temp;

use lib $*PROGRAM.parent(2).child('lib');
use Pod::Convenience;
use Test-Files;

=begin SYNOPSIS

Verify that any X references in the documentation use one of the specific
whitelisted categories in this file. This helps the search function on the
site be cohesive and more useful for the end user.

=end SYNOPSIS

# Use list of allowed categories from documentations
my @categories = 'writing-docs/INDEXING.md'.IO.lines\
    .grep(*.starts-with('* `'))\
    .map({$_ ~~ / '* `' (<-[`]>*)/; ~$0})\
    .sort;

plan +(my @files = Test-Files.pods.grep({ not $_.contains('about')})) + 1;

my %*used-categories;

for @files -> $file {
    subtest $file => {
        my @examples = refs($file);
        test-ref $_ for @examples;
    }
}

# Note: if run on a subset of files, this will report false positives
subtest "Category usage" => {
    for @categories -> $category {
        ok %*used-categories{$category}:exists, "Category「$category」is used in documentation";
    }
}

sub test-ref ($ref) {
    my $contents = $ref<contents>.cache;
    for $contents<> -> $item {
        my $category = $item[0];
        is $item.elems, 2, "Correct dimension (2) for a search anchor '$contents.Str()' $ref<file>";
        ok $item[0] (elem) @categories, "「$category」is a valid category";
        %*used-categories{$category}++;
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
