#!/usr/bin/env perl6
#
use v6;
use lib 'lib';
use Perl6::TypeGraph;

=begin pod

=head1 NAME

    missing-methods

=head1 SYNOPSIS

    $ perl6 util/missing-methods.p6

=head1 DESCRIPTION

A first cut at a program to find methods in a Perl 6 implementation which
have not yet been documented.

At present this involves a call to C<p6doc> in order to find if the methods
found have documentation.  This could be improved by simply calling the
relevant routines within C<p6doc> instead of accessing the functionality
from outside.

=end pod

my $t = Perl6::TypeGraph.new-from-file('type-graph.txt');

for $t.sorted -> $type {
    my $type_name = ::($type.name);
    my @methods = $type_name.^methods(:local);
    for @methods -> $method {
        my $qualified_method_name = $type.name ~ '.' ~ $method.name;
        my $doc_output = qqx{PAGER=cat ./bin/p6doc -f $qualified_method_name};
        say "$qualified_method_name" if $doc_output ~~ m:s/No documentation found/;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
