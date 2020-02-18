#!/usr/bin/env perl6

use v6;

{
    # Cache no worries pragma; workaround for https://github.com/rakudo/rakudo/issues/1630
    # to avoid warnings produced from regexes when we're compiling examples.
    no worries;
    "" ~~ /./;
}

use Test;
use File::Temp;

use lib 'lib';
use Pod::Convenience;
use Test-Files;

=begin SYNOPSIS

Test all of the code samples in the document files. Wrap snippets
in enough boilerplate so that we are just compiling and not executing
wherever possible. Allow some magic for method declarations to
avoid requiring a body.

Skip any bits marked C<:skip-test> unless the environment variable
C<P6_DOC_TEST_FUDGE> is set to a true value.

Note: This test generates a lot of noisy output to stderr; we
do hide $*ERR, but some of these are emitted from parts of
the compiler that only know about the low level handle, not the
Perl 6 level one.

=end SYNOPSIS

plan +my @files = Test-Files.pods;

for @files -> $file {
    subtest $file => {
        plan +my @examples = code-blocks($file);
        test-example $_ for @examples;
    }
}

sub test-example ($eg) {
    # #1355 - don't like .WHAT in examples
    if ! $eg<ok-test>.contains('WHAT') && $eg<contents>.contains('.WHAT') {
        flunk "$eg<file> chunk starting with «" ~ starts-with($eg<contents>) ~ '» uses .WHAT: try .^name instead';
        next;
    }
    if ! $eg<ok-test>.contains('dd') && $eg<contents> ~~ / << 'dd' >> / {
        flunk "$eg<file> chunk starting with «" ~ starts-with($eg<contents>) ~ '» uses dd: try say instead';
        next;
    }

    # Wrap snippets in an anonymous class (so bare method works)
    # and add in empty blocks if needed.

    my $code;
    if $eg<solo> {
        $code  = $eg<preamble> ~ ";\n" if $eg<preamble>;
        $code ~= $eg<contents>;
    }
    else {
        $code  = 'no worries; ';
        $code ~= "class :: \{\n";
        $code ~= $eg<preamble> ~ ";\n";

        for $eg<contents>.lines -> $line {
            state $in-signature;

            $code ~= $line;
            # Heuristically add an empty block after things like C<method foo ($x)>
            # to make it compilable. Be careful with multiline signatures:
            # '(' and ',' at the end of a line indicate a continued sig.
            # We wait until none of them is encountered before adding '{}'.
            # Cases that are not covered by the heuristic and which contain
            # nothing but a method declaration can use :method instead.
            $in-signature ?|= $line.trim.starts-with(any(<multi method proto only sub>))
                           && not $eg<method>;
            if $in-signature && !$line.trim.ends-with(any(« } , ( »)) {
               $code ~= " \{}";
               $in-signature = False;
            }
            NEXT $code ~= "\n";
            LAST $code ~= "\{}\n" if $eg<method>;
        }
        $code ~= "}";
    }

    my $msg = "$eg<file> chunk $eg<count> starts with “" ~ starts-with($eg<contents>) ~ "” compiles";

    my $has-error;
    my $error-reason;
    {
        # Does the test require its own file?
        if $eg<solo> {
            my ($tmp_fname, $tmp_io) = tempfile;
            $tmp_io.spurt: $code, :close;
            my $proc = Proc::Async.new($*EXECUTABLE, '-c', $tmp_fname);
            $proc.stdout.tap: {;};
            $proc.stderr.tap: {$error-reason ~= $_};
            $has-error = ! await $proc.start;
        }
        else {
            temp $*OUT = open :w, $*SPEC.devnull;
            temp $*ERR = open :w, $*SPEC.devnull;
            use nqp;
            my $*LINEPOSCACHE;
            my $parser = nqp::getcomp('Raku') || nqp::getcomp('perl6');
            $has-error = not try { $parser.parse($code) };
            $error-reason = $! if $!;
            close $*OUT;
            close $*ERR;

        }
    }

    todo(1) if $eg<todo>;
    if $has-error {
        diag $eg<contents>;
        diag $error-reason;
        flunk $msg;
    }
    else {
        pass $msg;
    }
}

sub code-blocks (IO() $file) {
    my $count;
    my @chunks = extract-pod($file).contents;
    gather while @chunks {
        my $chunk = @chunks.pop;
        if $chunk ~~ Pod::Block::Code  {
            # Only testing Perl 6 snippets.
            next unless $chunk.config<lang>:v eq '' | 'perl6';

            my $todo = False;
            if $chunk.config<skip-test> {
                %*ENV<P6_DOC_TEST_FUDGE> ?? ($todo = True) !! next;
            }
            take %(
                'contents',  $chunk.contents.map({walk $_}).join,
                'file',      $file,
                'count',     ++$count,
                'todo',      $todo,
                'ok-test',   $chunk.config<ok-test> // "",
                'preamble',  $chunk.config<preamble> // "",
                'method',    $chunk.config<method>:v,
                'solo',      $chunk.config<solo>:v,
            );
        }
        else {
            if $chunk.^can('contents') {
                @chunks.push(|$chunk.contents)
            }
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

sub starts-with (Str $chunk) {
    ($chunk.lines)[0].substr(0,10).trim
}
