unit module Pod::Convenience;

sub pod-gist(Pod::Block $pod, $level = 0) is export {
    my $leading = ' ' x $level;
    my %confs;
    my @chunks;
    for <config name level caption type> {
        my $thing = $pod.?"$_"();
        if $thing {
            %confs{$_} = $thing ~~ Iterable ?? $thing.perl !! $thing.Str;
        }
    }
    @chunks = $leading, $pod.^name, (%confs.perl if %confs), "\n";
    for $pod.contents.list -> $c {
        if $c ~~ Pod::Block {
            @chunks.push: pod-gist($c, $level + 2);
        }
        elsif $c ~~ Str {
            @chunks.push: $c.indent($level + 2), "\n";
        } elsif $c ~~ Positional {
            @chunks.push: $c.map: {
                if $_ ~~ Pod::Block {
                    *.&pod-gist
                } elsif $_ ~~ Str {
                    $_
                }
            }
        }
    }
    @chunks.join;
}

sub first-code-block(@pod) is export {
    if @pod[1] ~~ Pod::Block::Code {
        return @pod[1].contents.grep(Str).join;
    }
    '';
}

sub pod-with-title($title, *@blocks) is export {
    Pod::Block::Named.new(
        name => "pod",
        contents => [
            flat pod-title($title), @blocks
        ]
    );
}

sub pod-title($title) is export {
    Pod::Block::Named.new(
        name    => "TITLE",
        contents => Array.new(
            Pod::Block::Para.new(
                contents => [$title],
            )
        )
    )
}

sub pod-block(*@contents) is export {
    Pod::Block::Para.new(:@contents);
}

sub pod-link($text, $url) is export {
    Pod::FormattingCode.new(
        type     => 'L',
        contents => [$text],
        meta     => [$url],
    );
}

sub pod-bold($text) is export {
    Pod::FormattingCode.new(
        type     => 'B',
        contents => [$text],
    );
}

sub pod-item(*@contents, :$level = 1) is export {
    Pod::Item.new(
        :$level,
        :@contents,
    );
}

sub pod-heading($name, :$level = 1) is export {
    Pod::Heading.new(
        :$level,
        :contents[pod-block($name)],
    );
}

sub pod-table(@contents) is export {
    Pod::Block::Table.new(
        :@contents
    )
}

sub pod-lower-headings(@content, :$to = 1) is export {
    my $by = @content.first(Pod::Heading).level;
    return @content unless $by > $to;
    my @new-content;
    for @content {
        @new-content.push($_ ~~ Pod::Heading
            ?? Pod::Heading.new: :level(.level - $by + $to) :contents[.contents]
            !! $_
        );
    }
    @new-content;
}

# vim: expandtab shiftwidth=4 ft=perl6
