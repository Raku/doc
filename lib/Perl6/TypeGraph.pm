use Perl6::Type;
class Perl6::TypeGraph {
    has %.types;
    has @.sorted;
    my grammar Decl {
        token ident      { <.alpha> \w*                }
        token apostrophe { <[ ' \- ]>                  }
        token identifier { <.ident> [ <.apostrophe> <.ident> ]* }
        token longname   { <identifier>+ % '::'        }
        token scoped     { 'my' | 'our' | 'has'        }
        token package    { pmclass | class | module | package |role | enum }
        token rolesig    { '[' <-[ \[\] ]>* ']' } # TODO might need to be become better
        rule  inherits   { 'is' <longname>             }
        rule  roles      { 'does' <longname><rolesig>? }

        rule TOP {
            ^
            <scoped>?
            <package>
            <type=longname><rolesig>?
            :my $*CURRENT_TYPE;
            { $*CURRENT_TYPE = $<type>.ast }
            [ <inherits> | <roles>]*
            $
        }
    }

    method new-from-file($fn) {
        my $n = self.bless;
        $n.parse-from-file($fn);
        $n;
    }

    method parse-from-file($fn) {
        my $f = open $fn;
        my $get-type = -> Str $name {
            %.types{$name} //= Perl6::Type.new(:$name);
        };
        my class Actions {
            method longname($/) {
                make $get-type($/.Str);
            }
            method inherits($/) {
                $*CURRENT_TYPE.super.push: $<longname>.ast;
            }
            method roles($/) {
                $*CURRENT_TYPE.roles.push: $<longname>.ast;
            }
        }
        my @categories;
        for $f.lines -> $l {
            next if $l ~~ / ^ '#' /;
            if $l ~~ / ^ \s* $ / {
                undefine @categories;
                next;
            }
            if $l ~~ / :s ^ '[' (\S+) + ']' $/ {
                @categories = @0>>.lc;
                next;
            }
            my $m = Decl.parse($l, :actions(Actions.new));
            my $t = $m<type>.ast;
            $t.packagetype = ~$m<package>;
            $t.categories = @categories;
        }
        for %.types.values -> $t {
            # roles that have a superclass actually apply that superclass
            # to the class that does them, so mimic that here:
            for $t.roles -> $r {
                $t.super.push: $r.super if $r.super;
            }
            # non-roles default to superclass Any
            if $t.packagetype ne 'role' && !$t.super && $t ne 'Mu' {
                $t.super.push: $get-type('Any');
            }
        }
        # Cache the inversion of all type relationships
        for %.types.values -> $t {
            $_.sub.push($t)   for $t.super;
            $_.doers.push($t) for $t.roles;
        }
        self!topo-sort;
    }
    method !topo-sort {
        my %seen;
        sub visit($n) {
            return if %seen{$n};
            %seen{$n} = True;
            visit($_) for flat $n.super, $n.roles;
            @!sorted.push: $n;
        }
        visit($_) for %.types.values.sort(*.name);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
