use Perl6::Type;
class Perl6::TypeGraph {
    has %.types;
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
        my $n = self.bless(*);
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
                $*CURRENT_TYPE.roles.push:  $<longname>.ast;
            }
        }
        for $f.lines -> $l {
            next if $l ~~ / ^ '#'   /;
            next if $l ~~ / ^ \s* $ /;
            my $m = Decl.parse($l, :actions(Actions.new));
            my $t = $m<type>.ast;
            $t.packagetype = ~$m<package>;
        }
    }
}

# vim: ft=perl6
