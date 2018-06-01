use Pod::To::Text;
class Pod::To::SectionFilter {
    method render(@pod) {
        my $search_for = %*ENV<PERL6_POD_HEADING> // die 'env var missing';
        my @blocks := @pod[0].contents;
        my $from;
        my $heading-level;
        for @blocks.kv -> $idx, $b {
            if $b ~~ Pod::Heading && $b.contents[0].contents[0] ~~ m:i:s/^ [method|sub|routine] $search_for $/ {
                $from = $idx;
                $heading-level = $b.level;
            }
        }
        return "No documentation found for method '$search_for'"
            unless defined $from;

        my $to = @blocks.end;
        for $from + 1 .. @blocks.end -> $i {
            if @blocks[$i] ~~ Pod::Heading && @blocks[$i].level <= $heading-level {
                $to = $i - 1;
                last;
            }
        }
        Pod::To::Text.render(@blocks[$from..$to]);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
