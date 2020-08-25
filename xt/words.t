#!/usr/bin/env perl6

use v6;
use Test;

use lib $*PROGRAM.parent(2).child('lib');

=begin overview

Verify setup of lexicon files used to drive C<xt/aspell.t>.

Avoid duplicates, verify header, lowercase, sorting.

=end overview

plan 6;

my @words = $*PROGRAM.parent.child('pws/words.pws').IO.lines;
my @code = $*PROGRAM.parent.child('pws/code.pws').IO.lines;

my $header = @words.shift;

is($header, 'personal_ws-1.1 en 0 utf-8', "header on xt/pws/words.pws is correct");

sub sorted(@lexicon) {
    return [&&] @lexicon.rotor(2 => -1).map({$_[0] lt $_[1]})
}

ok(sorted(@words), "xt/pws/words.pws is sorted");
ok(sorted(@code), "xt/pws/code.pws is sorted");

my @dupes = @words.Set ∩ @code.Set;

is(~@dupes, "", "No duplicates between xt/pws/words.pws and xt/pws/code.pws");

# are all the words lower case?
# (ignore some unicode that aspell doesn't case fold as well as we do.
sub get-uppers(@lexicon) {
    @lexicon.grep({ .lc ne $_ }).grep({ ! $_.contains('Þ') })
}

my $uppers = get-uppers(@words);
is($uppers.elems, 0, "all words in xt/pws/words.pws are lowercase");
diag $uppers if $uppers.elems;

$uppers = get-uppers(@code);
is($uppers.elems, 0, "all words in xt/pws/code.pws are lowercase");
diag $uppers if $uppers.elems;

