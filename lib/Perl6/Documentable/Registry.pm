use v6;
use Perl6::Documentable;

class Perl6::Documentable::Registry {
    has @.documentables;
    has Bool $.composed = False;
    has %!cache;
    has %!grouped-by
    method add-new(*%args) {
        die "Cannot add something to a composed registry" if $.composed;
        @!documentables.push: Perl6::Documentable.new(|%args);
        1;
    }
    method compose() {
        $!composed = True;
    }
    method grouped-by(Str $what) {
        die "You need to compose this registry first" unless $.composed;
        %!grouped-by ||= @!documentables.classify(*."$what"());
    }
    method lookup(Str $what, Str :$by!) {
        unless %!cache.exists($by) {
            for @!documentables -> $d {
                %!cache{$by}{$d."$by"()}.push: $d;
            }
        }
        %!cache{$by}{$d};
    }
}
