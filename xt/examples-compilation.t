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

I<Note>: Because of our use of C<EVAL>, avoid concurrency.

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

for @files -> $file {
    my $counts = 0;
    my @chunks = extract-pod($file.IO).contents;
    while @chunks {
        my $chunk = @chunks.pop;
        if $chunk ~~ Pod::Block::Code  {
            if $chunk.config<lang> && $chunk.config<lang> ne 'perl6' {
                next; # Only testing Perl 6 snippets.
            }
            my $todo = False;
            if $chunk.config<skip-test> {
                %*ENV<P6_DOC_TEST_FUDGE> ?? ($todo = True) !! next;
            }
            check-chunk( %(
                'contents',  $chunk.contents.map({walk $_}).join,
                'file',      $file,
                'count',     ++$counts,
                'todo',      $todo,
                'ok-test',   $chunk.config<ok-test> // "",
                'preamble',  $chunk.config<preamble> // "",
                'method',    $chunk.config<method> // "",
                'solo',      $chunk.config<solo> // "",
            ) );
        } else {
            if $chunk.^can('contents') {
                @chunks.push(|$chunk.contents)
            }
        }
    }
}

done-testing;

sub check-chunk( $eg ) {
    use MONKEY-SEE-NO-EVAL;

    # #1355 - don't like .WHAT in examples
    if ! $eg<ok-test>.contains('WHAT') && $eg<contents>.contains('.WHAT') {
        flunk "$eg<file> chunk starting with «" ~ starts-with($eg<contents>) ~ '» uses .WHAT: try .^name instead';
        next;
    }
    if ! $eg<ok-test>.contains('dd') && $eg<contents> ~~ / << 'dd' >> / {
        flunk "$eg<file> chunk starting with «" ~ starts-with($eg<contents>) ~ '» uses dd: try say instead';
        next;
    }

    # Wrap each snippet in a block so it compiles but isn't run on EVAL
    # Further wrap in an anonymous class (so bare method works)
    # Add in empty routine bodies if needed

    my $code;
    if $eg<solo> {
        $code = $eg<preamble> ~ ";\n" if $eg<preamble>;
        $code ~= $eg<contents>;
    } else {
        $code = 'no worries; ';
        $code ~= "if False \{\nclass :: \{\n";
        $code ~= $eg<preamble> ~ ";\n";

        for $eg<contents>.lines -> $line {
            state $in-signature;

            $code ~= $line;
            # Heuristically add an empty block after things like C<method foo ($x)>
            # to make it compilable. Be careful with multiline signatures:
            # '(' and ',' at the end of a line indicate a continued sig.
            # We wait until none of them is encountered before adding '{}'.
            $in-signature ?|= $line.trim.starts-with(any(<multi method proto only sub>))
                           && $eg<method> eq "";
            if $in-signature && !$line.trim.ends-with(any(« } , ( »)) {
               $code ~= " \{}";
               $in-signature = False;
            }
            if $eg<method> eq "" || $eg<method> eq "False" {
                $code ~= "\n";
            }
        }
        $code ~= "\{}\n" if $eg<method> eq "True";
        $code ~= "\n}}";
    }

    my $msg = "$eg<file> chunk $eg<count> starts with “" ~ starts-with($eg<contents>) ~ "” compiles";

    my $has-error;
    {
        # Does the test require its own file?
#        if $eg<solo> {
            my ($tmp_fname, $tmp_io) = tempfile;
            $tmp_io.spurt: $code, :close;
            my $proc = Proc::Async.new($*EXECUTABLE, '-c', $tmp_fname);
            $proc.stdout.tap: {;};
            $proc.stderr.tap: {;};
            $has-error = ! await $proc.start;
        # } else {
        #     temp $*OUT = open :w, $*SPEC.devnull;
        #     temp $*ERR = open :w, $*SPEC.devnull;
        #     try EVAL $code;
        #     $has-error = $!;
        #     close $*OUT;
        #     close $*ERR;
        # }
    }

    todo(1) if $eg<todo>;
    if $has-error {
        diag $eg<contents>;
        diag $has-error;
        flunk $msg;
    } else {
        pass $msg;
    }
}

sub starts-with( Str $chunk ) {
    ($chunk.lines)[0].substr(0,10).trim
}
