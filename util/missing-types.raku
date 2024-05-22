#!/usr/bin/env raku

# This script parses the type-graph.txt file and checks
# the existence of the corresponding rakudoc file for most entries
# skips: Metamodel and PROCESS types

use lib 'lib';
use Doc::TypeGraph;

# These are core but not loaded by default.
use Telemetry;
use Test;

my $t = Doc::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted  -> $type {
    next if $type.name.index('Metamodel').defined || $type.name eq 'PROCESS';
    my $actual = try ::($type.name);
    printf "%-40s not defined in this version of Raku\n", $type.name()
        if $actual === Any and $type.name ne "Any" | "Failure" | "Nil";
    next unless $actual.^name eq $type.name;
    my $filename = 'doc/Type/' ~ $type.name.subst(:g, '::', '/') ~ '.rakudoc';
    printf "%-40s not found in documentation\n", $type.name() unless $filename.IO.e;
    CATCH { default { } }
}
