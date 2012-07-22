class Perl6::TypeGraph {
    has %.types;
    class Type {
        has Str $.name handles <Str>;
        has @.super;
        has @.roles;
        has $.packagetype is rw = 'class';

        has @.mro;
        method mro(Type:D:) {
            return @!mro if @!mro;
            if @.super == 1 {
                @!mro = @.super[0].mro;
            } elsif @.super > 1 {
                my @merge_list = @.super.map: *.mro.item;
                @!mro = self.c3_merge(@merge_list);
            }
            @!mro.unshift: self;
        }

        method c3_merge(@merge_list) {
            my @result;
            my $accepted;
            my $something_accepted = 0;
            my $cand_count = 0;
            for @merge_list -> @cand_list {
                next unless @cand_list;
                my $rejected = 0;
                my $cand_class = @cand_list[0];
                $cand_count++;
                for @merge_list {
                    next if $_ === @cand_list;
                    for 1..+$_ -> $cur_pos {
                        if $_[$cur_pos] === $cand_class {
                            $rejected = 1;
                            last;
                        }
                    }
                }
                unless $rejected {
                    $accepted = $cand_class;
                    $something_accepted = 1;
                    last;
                }
            }
            return () unless $cand_count;
            unless $something_accepted {
                die("Could not build C3 linearization for {self}: ambiguous hierarchy");
            }
            for @merge_list.keys -> $i {
                @merge_list[$i] = [@merge_list[$i].grep: { $_ ne $accepted }] ;
            }
            @result = self.c3_merge(@merge_list);
            @result.unshift: $accepted;
            @result;
        }
    }
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
            %.types{$name} //= Type.new(:$name);
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
