use Pod::To::Text;
class Pod::To::SectionFilter {
    method render(@pod) {
        my $search_for = %*ENV<PERL6_POD_HEADING> // die 'env var missing';
        my @blocks := @pod[0].content;
        my $from;
        my $heading-level;
        for @blocks.kv -> $idx, $b {
            if $b ~~ Pod::Heading && $b.content[0].content[0] eq $search_for {
                $from = $idx;
                $heading-level = $b.level;
            }
        }
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
