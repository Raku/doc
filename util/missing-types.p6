#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Perl6::TypeGraph;

my $t = Perl6::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted  -> $type {
    next if $type.name.index('Metamodel').defined || $type.name eq 'PROCESS';
    my $actual = try ::($type.name);
    printf "%-40s not defined in this Perl\n", $type.name()
        if $actual === Any and $type.name ne "Any" | "Failure" | "Nil";
    next unless $actual.^name eq $type.name;
    my $filename = 'doc/Type/' ~ $type.name.subst(:g, '::', '/') ~ '.pod6';
    printf "%-40s not found in documentation\n", $type.name() unless $filename.IO.e;
    CATCH { default { } }
}

# vim: expandtab shiftwidth=4 ft=perl6
