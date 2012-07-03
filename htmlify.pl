#!/usr/bin/env perl6
use v6;
use Pod::To::HTML;

# this script isn't in bin/ because it's not meant
# to be installed.

my %names;
my %types;
my %routines;

sub MAIN($out_dir = 'html') {
    for ('', <type language>) {
        mkdir "$out_dir/$_" unless "$out_dir/$_".IO ~~ :e;
    }

    # TODO:  be recursive instead
    my @source = dir('lib').grep(*.f).grep(rx{\.pod$});

    my $tempfile = join '-', "tempfile", $*PID, (1..1000).pick ~ '.temp';

    for (@source) {
        my $podname = .basename.subst(rx{\.pod$}, '').subst(:g, '/', '::');
        my $what = $podname ~~ /^<[A..Z]> | '::'/  ?? 'type' !! 'language';
        say "$_.path() => $what/$podname";
        %names{$podname}{$what}.push: "/$what/$podname";
        %types{$what}{$podname} =    "/$what/$podname";
        shell("perl6 --doc=HTML $_.path() > $out_dir/$what/$podname.html");

        shell("perl6 -Ilib --doc=Serialization $_.path() > $tempfile");
        # assume just one pod block for now
        my ($pod) = eval slurp $tempfile;
        my @chunks = chunks-grep($pod.content,
                :from({ $_ ~~ Pod::Heading and .level == 2}),
                :to({ $^b ~~ Pod::Heading and $^b.level <= $^a.level}),
            );
        for @chunks -> $chunk {
            my $name = $chunk[0].content[0].content[0];
            next if $name ~~ /\s/;
            %names{$name}<routine>.push: "/type/$podname.html#$name";
            %routines{$name}.push: $chunk;
        }
        unlink $tempfile;
    }
    write-index-file($out_dir);
    # TODO: write per-routine docs
    # TODO: write top-level disambiguation files
}

sub chunks-grep(:$from!, :&to!, *@elems) {
    my @current;

    gather {
        for @elems -> $c {
            if @current && ($c ~~ $from || to(@current[0], $c)) {
                take [@current];
                @current = ();
            }
            elsif @current or $c ~~ $from {
                @current.push: $c;
            }
        }
        take [@current] if @current;
    }
}

sub write-index-file($out_dir) {
    my $pod = Pod::Block::Named.new(
        name => "pod",
        content => Array.new(
            Pod::Block::Named.new(
                name => "TITLE",
                content => Array.new(
                    Pod::Block::Para.new(
                        content => ["Perl 6 Documentation"],
                    )
                )
            ),
            Pod::Block::Para.new(
                content => ['Official Perl 6 documentation'],
            ),
            # TODO: add more
            Pod::Heading.new(
                level => 1,
                content => Array.new(
                    Pod::Block::Para.new(content => ["Language Documentation"])
                )
            ),
            %types<language>.pairs.sort.map({
                Pod::Item.new(
                    level => 1,
                    content =>  [
                        Pod::FormattingCode.new(
                            type    => 'L',
                            content => [
                                .key ~ '|' ~ .value;
                            ],
                        ),
                    ],
                );
            }),
            Pod::Heading.new(
                level => 1,
                content => Array.new(
                    Pod::Block::Para.new(content => ["Types"])
                )
            ),
            %types<type>.sort.map({
                Pod::Item.new(
                    level => 1,
                    content =>  [
                        Pod::FormattingCode.new(
                            type    => 'L',
                            content => [
                                .key ~ '|' ~ .value;
                            ],
                        ),
                    ],
                ),
            }),
        )
    );
    my $file = open :w, "$out_dir/index.html";
    $file.print: pod2html($pod);
    $file.close;
}
