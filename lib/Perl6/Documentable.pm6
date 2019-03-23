use URI::Escape;
class Perl6::Documentable {
    # Perl6::Documentable Represents a piece of Perl 6 that is documented.
    # It contains meta data about what is documented
    # (for example (kind => 'type', subkinds => ['class'], name => 'Code')
    # and in $.pod a reference to the actual documentation.

    has Str $.kind;        # type, language doc, routine, module
    has Bool $.section;     # for Language doc list breakdown by sections
    has Str @.subkinds;    # class/role/enum, sub/method, prefix/infix/...
    has Str @.categories;  # basic type, exception, operator...

    has Str $.name;
    has Str $.url;
    has     $.pod;
    has Bool $.pod-is-complete;
    has Str $.summary = '';

    # the Documentable that this one was extracted from, if any
    has $.origin;

    # Remove itemization from incoming arrays
    method new (:$categories = [], :$subkinds = [], *%_) {
        nextwith |%_, :categories($categories.list), :subkinds($subkinds.list);
    }

    my sub english-list (*@l) {
        @l > 1
            ?? @l[0..*-2].join(', ') ~ " and @l[*-1]"
            !! ~@l[0]
    }
    method human-kind() {   # SCNR
        $.kind eq 'language'
            ?? 'language documentation'
            !! @.categories eq 'operator'
            ?? "@.subkinds[] operator"
            !! english-list @.subkinds // $.kind;
    }

    method url() {
        $!url //= $.kind eq 'operator'
            ?? "/language/operators#" ~ uri_escape("@.subkinds[] $.name".subst(/\s+/, '_', :g))
            !! ("", $.kind, $.name).map(&uri_escape).join('/')
            ;
    }
    method categories() {
        @!categories //= @.subkinds
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
