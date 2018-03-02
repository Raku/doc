use v6;
use OO::Monitors;
use Perl6::Documentable;

monitor Perl6::Documentable::Registry {
    has @.documentables;
    has Bool $.composed = False;
    has %!cache;
    has %!grouped-by;
    has @!kinds;
    method add-new(*%args) {
        die "Cannot add something to a composed registry" if $.composed;
        @!documentables.append: my $d = Perl6::Documentable.new(|%args);
        $d;
    }
    method compose() {
        @!kinds = @.documentables>>.kind.unique;
        $!composed = True;
    }
    method grouped-by(Str $what) {
        die "You need to compose this registry first" unless $.composed;
        %!grouped-by{$what} ||= @!documentables.classify(*."$what"());
    }
    method lookup(Str $what, Str :$by!) {
        unless %!cache{$by}:exists {
            for @!documentables -> $d {
                %!cache{$by}{$d."$by"()}.append: $d;
            }
        }
        %!cache{$by}{$what} // [];
    }

    method get-kinds() {
        die "You need to compose this registry first" unless $.composed;
        @!kinds;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
