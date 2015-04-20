use v6;

use lib 'lib';
use Perl6::TypeGraph;

=begin pod

=head1 NAME

    missing-methods

=head1 SYNOPSIS

    $ perl6 util/missing-methods.p6 [--type_name=<Str>]

=head1 DESCRIPTION

A first cut at a program to find methods in a Perl 6 implementation which
have not yet been documented.

At present this involves a call to C<p6doc> in order to find if the methods
found have documentation.  This could be improved by simply calling the
relevant routines within C<p6doc> instead of accessing the functionality
from outside.

=end pod

sub MAIN(Str :$type-name) {
    my $type-graph = Perl6::TypeGraph.new-from-file('type-graph.txt');
    my @types-to-search = $type-name ?? $type-graph.types{$type-name}
                                     !! $type-graph.sorted;

    for @types-to-search -> $type {
        for methods-in-type($type) -> $method {
            show-undoc-method($type.name ~ '.' ~ $method.name);
        }
    }
}

sub methods-in-type($type) {
    my $type-name = ::($type.name);
    return $type-name.^methods(:local);
}

sub show-undoc-method(Str $qualified-method-name) {
    my $doc-lookup-command = "PAGER=cat ./bin/p6doc -f \'$qualified-method-name\'";
    my $doc-output = qqx{$doc-lookup-command};
    say "$qualified-method-name" if $doc-output ~~ m:s/No documentation found/;
}

# vim: expandtab shiftwidth=4 ft=perl6
