#!/usr/bin/env perl6
use v6;
use Pod::To::HTML;

# this script isn't in bin/ because it's not meant
# to be installed.

my %names;
my %types;
my %routines;

sub MAIN($out_dir = 'html') {
    for ('', <type language routine>) {
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
        next if $what eq 'language';

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
            %routines{$name}.push: $podname => $chunk;
            %types<routine>{$name} = "/routine/$name";
        }
        unlink $tempfile;
    }
    write-index-file(:$out_dir);
    for %routines.kv -> $name, @chunks {
        write-routine-file(:$out_dir, :$name, :@chunks);
    }
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

sub pod-with-title($title, *@blocks) {
    Pod::Block::Named.new(
        name => "pod",
        content => [
            Pod::Block::Named.new(
                name => "TITLE",
                content => Array.new(
                    Pod::Block::Para.new(
                        content => [$title],
                    )
                )
            ),
            @blocks,
        ]
    );
}

sub pod-block(*@content) {
    Pod::Block::Para.new(:@content);
}

sub pod-link($text, $url) {
    Pod::FormattingCode.new(
        type    => 'L',
        content => [
            join('|', $text, $url),
        ],
    );
}

sub pod-item(*@content, :$level = 1) {
    Pod::Item.new(
        :$level,
        :@content,
    );
}

sub pod-heading($name, :$level = 1) {
    Pod::Heading.new(
        :$level,
        :content[pod-block($name)],
    );
}

sub write-index-file(:$out_dir!) {
    say "Writing $out_dir/index.html";
    my $pod = pod-with-title('Perl 6 Documentation',
        Pod::Block::Para.new(
            content => ['Official Perl 6 documentation'],
        ),
        # TODO: add more
        pod-heading("Language Documentation"),
        %types<language>.pairs.sort.map({
            pod-item( pod-link(.key, .value) )
        }),
        pod-heading('Types'),
        %types<type>.sort.map({
            pod-item(pod-link(.key, .value))
        }),
        pod-heading('Routines'),
        %types<routine>.sort.map({
            pod-item(pod-link(.key, .value))
        }),
    );
    my $file = open :w, "$out_dir/index.html";
    $file.print: pod2html($pod);
    $file.close;
}

sub write-routine-file(:$name!, :$out_dir!, :@chunks!) {
    say "Writing $out_dir/routine/$name.html";
    my $pod = pod-with-title("Documentation for routine $name",
        pod-block("Documentation for routine $name, assembled from the
            following types:"));
    $pod.content.push: @chunks.map(-> Pair (:key($type), :value($chunk)) {
            pod-heading($type),
            pod-block("From ", pod-link($type, "/type/{$type}#$name")),
            @$chunk
        });
    my $file = open :w, "$out_dir/routine/$name.html";
    $file.print: pod2html($pod);
    $file.close;
} 
