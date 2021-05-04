#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Make sure certain words are normalized by checking regular expressions.

=end overview

my @files = Test-Files.pods;

my %variants = %(
    # no lowercase 'boolean', unless it is followed by some selected
    # characters as it might be included in a code snippet,
    # see for example doc/Language/js-nutshell.pod6
    Boolean    => rx/ << boolean <!before \s* <[ \= \< \> \{ \} ]> > /,
    filehandle => rx:i/ << file [\s+|\-] handle /,
    filesystem => rx:i/ << file [\s+|\-] system /,
    lookahead  => rx:i/ << look \- ahead /,
    lookbehind => rx:i/ << look [\s+|\-] behind /,
    meta      => rx:i/ << <!after [ method || \$ || \- || \" ] \s*> meta [\s+|\-] << <!before ok >> > /,
    metadata  => rx:i/ << meta [\s+|\+] data /,
    NYI        => rx:i/ << niy /,
    precompil => rx:i/ << pre \- compil /,
    runtime    => rx:i/ << run [\s+|\-] time /,
    semicolon => rx:i/ << semi [\s+|\-] colon /,
    shorthand  => rx:i/ << short [\s+|\-] hand /,
    sigiled => rx:i/ << sigilled /,
    smartmatch => rx:i/ << smart  [\s+|\-] match /,
    subdirectory => rx:i/ << sub \- directory /,
    zero-width => rx:i/ << zero \s+ width<!before ' joiner'><!before ' no-break space'> /,
);

plan +@files;

my %result;

for @files.race -> $file {
    my $ok = True;
    my $row = 0;
    my @bad;
    my $content =  $file.IO.slurp.lines.join(" ");
    for %variants.kv -> $word, $rx {
        if $content ~~ $rx {
            $ok = False;
            @bad.push: "«$/» found. We prefer ｢$word｣";
        }
    }
    %result{$file} = [$ok, @bad];
}

for %result.keys.sort -> $file {
    my $result = $file;
    my $ok = %result{$file}[0];
    my @bad = %result{$file}[1];
    if !$ok {
       $result ~= " {@bad.join: ', '}): Certain words should be normalized. ";
    }
    ok $ok, $result;
}

# vim: expandtab shiftwidth=4 ft=perl6
