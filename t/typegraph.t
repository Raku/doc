use v6;
use Test;
use lib 'lib';
use Perl6::TypeGraph;

my $t = Perl6::TypeGraph.new-from-file('type-graph.txt');
ok $t, 'Could parse the file';
ok $t.types<Array>, 'has type Array';
ok $t.types<Array>.super.any eq 'List',
    'Array has List as a superclass';
ok $t.types<List>.roles.any eq 'Positional',
    'List does positional';
done;
