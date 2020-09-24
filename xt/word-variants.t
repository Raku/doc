#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Make sure certain words are normalized by checking regular expressions.

=end overview

my @files = Test-Files.pods;

my %variants = %(
    filehandle => 'file [\s+|\-] handle',
    filesystem => 'file [\s+|\-] system',
    lookahead  => 'look \- ahead',
    lookbehind => 'look [\s+|\-] behind',
    meta      => '<!after [ method || \$ || \- || \" ] \s*> meta
[\s+|\-]
<<',
    metadata  => 'meta [\s+|\+] data',
    NYI        => 'niy',
    precompil => 'pre \- compil',
    runtime    => 'run [\s+|\-] time',
    semicolon => 'semi [\s+|\-] colon',
    shorthand  => 'short [\s+|\-] hand',
    sigiled => 'sigilled',
    smartmatch => 'smart  [\s+|\-] match',
    zero-width => 'zero \s+ width<!before \' joiner\'><!before \' no-break space\'>',
);

plan +@files;

for @files.sort -> $file {
    my $ok = True;
    my $row = 0;
    my @bad;
    my $content =  $file.IO.slurp.lines.join(" ");
    for %variants.kv -> $word, $rx {
        if $content ~~ m/:i << <{$rx}> / {
            $ok = False;
            @bad.push: "«$/» found. We prefer ｢$word｣";
        }
    }
    my $result = $file;
    if !$ok {
        $result ~= " {@bad.join: ', '}): Certain words should be normalized. ";
    }
    ok $ok, "$result" ;
}

# vim: expandtab shiftwidth=4 ft=perl6
