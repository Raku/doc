#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Perl6::TypeGraph;

my $t = Perl6::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted  -> $type {
    next if $type.name.index('Metamodel').defined || $type.name eq 'PROCESS';
    next unless ::($type).^name eq $type.name;
    my $filename = 'lib/Type/' ~ $type.name.subst(:g, '::', '/') ~ '.pod';
    say $type.name unless $filename.IO.e;
    CATCH { default { } }
}

# vim: expandtab shiftwidth=4 ft=perl6
