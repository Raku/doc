use v6;

class Perl6::Type {
    has Str $.name handles <Str>;
    has @.super;
    has @.sub;
    has @.roles;
    has @.doers;
    has $.packagetype is rw = 'class';
    has $.aka is rw;
    has @.categories;

    has @.mro;
    method mro(Perl6::Type:D:) {
        return @!mro if @!mro;
        if @.super == 1 {
            @!mro = @.super[0].mro;
        } elsif @.super > 1 {
            my @merge_list = @.super.map: *.mro.item;
            @!mro = self.c3_merge(@merge_list);
        }
        if $!aka {
            @!mro.unshift: $!aka;
        } else {
            @!mro.unshift: self;
        }
        @!mro;
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

# vim: expandtab shiftwidth=4 ft=perl6
