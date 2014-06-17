module Pod::Convenience;

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
    for $pod.content.list -> $c {
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
        return @pod[1].content.grep(Str).join;
    }
    '';
}

sub pod-with-title($title, *@blocks) is export {
    Pod::Block::Named.new(
        name => "pod",
        content => [
            pod-title($title),
            @blocks.flat,
        ]
    );
}

sub pod-title($title) is export {
    Pod::Block::Named.new(
        name    => "TITLE",
        content => Array.new(
            Pod::Block::Para.new(
                content => [$title],
            )
        )
    )
}

sub pod-block(*@content) is export {
    Pod::Block::Para.new(:@content);
}

sub pod-link($text, $url) is export {
    Pod::FormattingCode.new(
        type    => 'L',
        content => [$text],
        meta    => [$url],
    );
}

sub pod-bold($text) is export {
    Pod::FormattingCode.new(
        type    => 'B',
        content => [$text],
    );
}

sub pod-item(*@content, :$level = 1) is export {
    Pod::Item.new(
        :$level,
        :@content,
    );
}

sub pod-heading($name, :$level = 1) is export {
    Pod::Heading.new(
        :$level,
        :content[pod-block($name)],
    );
}

sub pod-table(@content) is export {
    Pod::Block::Table.new(
        :@content
    )
}
