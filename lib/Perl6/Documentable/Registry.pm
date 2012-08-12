use v6;
use Perl6::Documentable;

class Perl6::Documentable::Registry {
    has @!documentables;
    method add-new(*%args) {
        @!documentables.push: Perl6::Documentable.new(|%args);
        1;
    }
}
