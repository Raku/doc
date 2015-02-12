#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Perl6::TypeGraph;

my $t = Perl6::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted  -> $type {
    next if $type.name.index('Metamodel').defined || $type.name eq 'PROCESS';
#    next unless ::($type).^name eq $type.name;
    next if $type.packagetype eq 'role';
    try {
        my $got = ~$type.mro;
        my $expected = ~::($type).^mro.map: *.^name;
        say "$got   vs    $expected" if $got ne $expected;
        CATCH {
            default {
                say "Trouble with $type: $_";
            }
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
