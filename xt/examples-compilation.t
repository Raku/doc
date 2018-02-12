#!/usr/bin/env perl6

use v6;
use Test;
use IO::String;

use lib 'lib';
use Pod::Convenience;

=begin overview

Test all of the code samples in the document files. Wrap snippets
in enough boilerplate that we are just compiling and not executing
wherever possible. Allow some magic for method declarations to
avoid requiring a body.

Skip any bits marked :skip-test unless the environment variable
P6_DOC_TEST_FUDGE is set to a true value.

=end overview

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(' ').grep(*.IO.e);
    } else {
        @files = qx<git ls-files doc>.lines;
    }
}

@files = @files.grep({$_.ends-with('.pod6')});

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
    for extract-pod($file.IO).contents -> $chunk {
        if $chunk ~~ Pod::Block::Code  {
            if $chunk.config<lang> && $chunk.config<lang> ne 'perl6' {
                next; # Only testing Perl 6 snippets.
            }
            my $todo = False;
            if $chunk.config<skip-test> {
                %*ENV<P6_DOC_TEST_FUDGE> ?? ($todo = True) !! next;
            }
            @examples.push: %(
                'contents',  $chunk.contents.map({walk $_}).join,
                'file',      $file,
                'count',     ++$counts{$file},
                'todo',      $todo,
                'ok-test',   $chunk.config<ok-test> // "",
                'preamble',  $chunk.config<preamble> // "",
                'method',    $chunk.config<method> // "",
            );
        }
    }
}

my $proc;
plan +@examples;

my $dummy-io = IO::String.new();
for @examples -> $eg {
    use MONKEY-SEE-NO-EVAL;

    # #1355 - don't like .WHAT in examples
    if ! $eg<ok-test>.contains('WHAT') && $eg<contents>.contains('.WHAT') {
        flunk "$eg<file> chunk $eg<count>" ~ ' uses .WHAT: try .^name instead';
        next;
    }
    if ! $eg<ok-test>.contains('dd') && $eg<contents> ~~ / << 'dd' >> / {
        flunk "$eg<file> chunk $eg<count>" ~ ' uses dd: try say instead';
        next;
    }

    # Wrap each snippet in a block so it compiles but isn't run on EVAL
    # Further wrap in an anonymous class (so bare method works)
    # Add in empty routine bodies if needed

    my $code = 'BEGIN $*LANG.set_pragma("no-worries",1);';
    $code ~= "if False \{\nclass :: \{\n";
    $code ~= $eg<preamble> ~ ";\n";

    for $eg<contents>.lines -> $line {
        $code ~= $line;
        if $line.trim.starts-with(any(<multi method proto only sub>)) && !$line.trim.ends-with(any('}',',')) && $eg<method> eq "" {
           $code ~= " \{}";
        }
        if $eg<method> eq "" || $eg<method> eq "False" {
            $code ~= "\n";
        }
    }
    $code ~= "\{}\n" if $eg<method> eq "True";
    $code ~= "\n}}";

    my $msg = "$eg<file> chunk $eg<count> starts with “" ~ ($eg<contents>.lines)[0].substr(0,10).trim ~ "” compiles";

    my $status;
    {
        $*OUT = $dummy-io;
        $*ERR = $dummy-io;
        try EVAL $code;
        $status = $!;
    }
    todo(1) if $eg<todo>;
    if $status {
        diag $eg<contents>;
        diag $status;
        flunk $msg;
    } else {
        pass $msg;
    }
}
