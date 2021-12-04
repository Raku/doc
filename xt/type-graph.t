#!/usr/bin/env raku

use Test;
use Doc::TypeGraph;
use Telemetry;

my $t = Doc::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted -> $type {
    next if $type.name.index('Metamodel').defined || $type.name eq 'PROCESS';
    next if $type.packagetype eq 'role'|'module';
    # these types does not support mro => whitelisted
    next if $type.name eq any(<Failure MOP Routine::WrapHandle Encoding UInt>);
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
