#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;

plan 9;

constant DOC-BIN = $*CWD.add('bin/p6doc');

# Copy docs program to temp dir sandbox, since it saves state there
use File::Temp;
my $sandbox = tempdir(:unlink).IO;
my $doc-bin = $sandbox.add(DOC-BIN.basename);
DOC-BIN.copy($doc-bin);

sub run-doc(*@args, :$interact = False, :$rc = 0) {
    my %env;
    # Add -I. so 'doc/' directory is found
    %env<RAKUDOLIB> = <. lib>.map({ $*CWD.add($_) }).join(',');
    %env<P6DOC_INTERACT> = 1 unless $interact === False;
    # XXX: This should be fixed in bin/p6doc itself, probably
    # Avoid hard-coded, non-portable 'less -r' in bin/p6doc
    %env<PAGER> = 'more';
    %env<TERM> = %*ENV<TERM> // 'unknown';

    my $in := $interact ~~ IO::Handle ?? $interact !! so $interact;

    my $proc = run :%env, :$in, :out, $*EXECUTABLE, $doc-bin, |@args;

    if $interact {
        if    $interact ~~ Iterable { $proc.in.put($_) for $interact }
        elsif $interact ~~ Cool     { $proc.in.put($interact)        }

        # See https://github.com/rakudo/rakudo/issues/3720
        my $dont-sink-and-die = $proc.in.close;
    }
    my $out := $proc.out.slurp.trim;
    my $exitcode = $proc.exitcode;

    is $exitcode, $rc,
        "run '@args[]', exitcode = $rc"
        or diag ("expected: $rc", "got: $exitcode", $out).join("\n");

    $out;
}

subtest "build index" => {
    plan 7;
    is run-doc('path-to-index'), '',
        "path-to-index is initially empty";
    is run-doc('build'), '',
        "build ok";
    is run-doc('path-to-index'), $sandbox.add('index.data'),
        "path-to-index";
    cmp-ok $sandbox.add('index.data').IO.s, &[>], 1000,
        "index.data is not empty";
}

subtest "basic lookup" => {
    plan 4;
    like run-doc('list'), / ^^ 'method say' $$ .* ^^ 'method starts-with' $$ /,
        "list";
    is run-doc('lookup', 'method say'), 'Type::Mu.',
        "lookup 'method say'";
}

sub check-found-page($out, $routine, :$type) {
    like $out, / [ ^^ | 'Narrow your choice' .* ':' \h*] In \h+ $type \h* $$ /,
        "gets page for Type"
        if $type;
    like $out, / ^^ \h* method \h+ $routine \h* $$ /,
        "mentions 'method $routine'";
}

sub check-ambiguous($out, $routine, :$type, :$found, :$interactive = True) {
    like $out, / 'Narrow your choice' /,
        "prompts for a choice"
        if $interactive;

    like $out, / 'multiple matches' \N* $routine /,
        "mentions multiple matches for $routine";

    like $out, / 'Type::' $type '.' $routine /,
        "mentions Type::{$type}.{$routine}"
        if $type;

    check-found-page($out, $routine, :$type)
        if $found;
}

subtest "specific bare routine '-f' lookup" => {
    plan 3;
    my $out = run-doc('-f', 'starts-with');
    check-found-page($out, 'starts-with', :type<Str>);
}

subtest "specific Type.routine '-f' lookup" => {
    plan 3;
    my $out = run-doc('-f', 'Mu.say');
    check-found-page($out, 'say', :type<Mu>);
}

subtest "ambiguous '-f' lookup" => {
    plan 3;
    my $out = run-doc('-f', 'say', :rc(1));
    check-ambiguous($out, 'say', :type<Mu>, :!interactive);
}

subtest "interactive '-f' lookup, empty response" => {
    plan 4;
    my $out = run-doc('-f', 'say', :interact(""), :rc(1));
    check-ambiguous($out, 'say', :type<Mu>);
}

subtest "interactive '-f' lookup, numeric response" => {
    plan 4;
    my $out = run-doc('-f', 'say', :interact("1"));
    # Not sure which Type will be first, so leave that off
    check-ambiguous($out, 'say', :found);
}

subtest "interactive '-f' lookup, invalid response" => {
    plan 5;
    my $out = run-doc('-f', 'say', :interact("meaningless text"), :rc(1));
    check-ambiguous($out, 'say', :type<Mu>);

    is ($out ~~ m:g/ 'Narrow your choice' /).elems, 2,
        "prompts twice for choice";
}

subtest "interactive '-f' lookup, substring response" => {
    plan 6;
    my $out = run-doc('-f', 'say', :interact("::Mu."));
    # Not sure which Type will be first, so leave that off
    check-ambiguous($out, 'say', :type<Mu>, :found);
}

# vim: expandtab shiftwidth=4 ft=perl6
