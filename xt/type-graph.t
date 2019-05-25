#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use Perl6::TypeGraph;

my $t = Perl6::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted -> $type {
    next if $type.name.index('Metamodel').defined || $type.name eq 'PROCESS';
    next if $type.packagetype eq 'role'|'module';
    next if $type.name eq 'Failure';
    try {
        my $got = ~$type.mro;
        my $expected = ~::($type).^mro.map: *.^name;
        is $got, $expected, $type;
        CATCH {
            default {
                flunk "Trouble with $type: $_";
            }
        }
    }
}

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
