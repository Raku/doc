#!/usr/bin/env raku

use lib $*PROGRAM.parent(2).child('lib');
use Test;

=begin overview

Verify that the version of rakudo used to run the tests is recent enough.

To avoid issues with a mismatch on source or compilation testing.

=end overview

plan 1;

my $min = v2021.12;

my $actual = $*RAKU.compiler.version;

ok $actual >= $min, "using at least version $min for testing";
