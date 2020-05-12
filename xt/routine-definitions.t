#!/usr/bin/env perl6

use Test;

use lib 'lib';
use Pod::Convenience;
use Test-Files;

=begin overview

Look for Pod sections about method, sub or routine and check that the
definitions in the first code blocks match the routine form specified in
the section heading.

ref #3350

=end overview

my @files = Test-Files.pods;

for @files -> $file {
    subtest $file => {
        my @headings =
            extract-pod($file.IO).contents.grep: Pod::Heading;

        plan +@headings.grep({ contents($_) ~~
            /^ \s* ( routine || sub || method ) \s+ <ident>+ \s* $/ });

        test-routine-definitions($file)
    }
}

sub test-routine-definitions($file) {
    my @chunks = extract-pod($file.IO).contents;
    my $routine-form;
    my Str $header;
    my Str $code;
    while @chunks {
        my $chunk = @chunks.shift;

        if $chunk ~~ Pod::Heading {
            # if we encounter a new section while we were parsing the
            # preceding one, check its definitions
            if $header && $routine-form {
              test-definitions($file, $header, $routine-form, $code);
            }

            # proceed with the new section
            $header = contents($chunk);
            if $header ~~ /^ \s* ( routine || sub || method ) \s+
                           <ident>+ \s* $/ {
                # it is a routine/sub/method section
                # we will start to parse it for definitions code blocks
                $routine-form = $0;
            } else {
                # it is not
                $routine-form = Any;
            }
        }

        # found a code block in a routine section : accumulate its code
        if $chunk ~~ Pod::Block::Code && $routine-form {
            $code ~= contents($chunk);
        }

        # found a non code block in a routine section after seeing some
        # code : assume we have collected all the code blocks of the
        # section containing the routine definitions and proceed to
        # check these definitions
        if $chunk !~~ Pod::Block::Code && $code && $routine-form {
            test-definitions($file, $header, $routine-form, $code);
        }
    }

    # is there a last section to check ?
    if $header && $routine-form {
        test-definitions($file, $header, $routine-form, $code);
    }
}

sub test-definitions($file, $header, $routine-form is rw, $code is rw) {
    # if there is no code, everything is fine
    if ! $code {
        ok 1, " section «" ~ $header ~ "»";
        $routine-form = Any;
        return;
    }

    # otherwise check definitions in the code
    my $error-reason;

    my $has_sub = so $code ~~ /^^ \h*
                                [  (multi \h+)? sub \h+ <ident>+
                                || multi \h+ <!before method> <ident>+
                                ]
				/;
    say "has_sub $has_sub";
    my $has_method =
        so $code ~~ /^^ \h* (multi \h+)? << method >>/;

    if $routine-form eq 'sub' && $has_method {
        $error-reason = 'has method definition';
    }

    if $routine-form eq 'method' && $has_sub {
        $error-reason = 'has sub definition';
    }

    if $routine-form eq 'routine' && !($has_sub || $has_method) {
        $error-reason = "lacks both sub and method definition";
    }

    if $error-reason {
        flunk $file ~ " section «" ~ $header ~
            "» but code block starting with «" ~
            starts-with($code) ~ "» $error-reason";
    } else {
        ok 1, " section «" ~ $header ~ "»";
    }

    # we're done with this section
    $routine-form = Any;
    $code = '';
}

sub contents($arg) {
    $arg.contents.map({walk $_}).join;
}

sub walk($arg) {
    given $arg {
        when Pod::FormattingCode { walk $arg.contents }
        when Pod::Block::Para    { walk $arg.contents }
        when Str   { $arg }
        when Array { $arg.map({walk $_}).join }
    }
}

sub starts-with (Str $str) {
    $str.substr(0,20).trim
}

# vim: expandtab shiftwidth=4 ft=perl6
