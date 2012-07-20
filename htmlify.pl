#!/usr/bin/env perl6
use v6;
use Pod::To::HTML;
use URI::Escape;

# this script isn't in bin/ because it's not meant
# to be installed.

sub url-munge($_) {
    return $_ if m{^ <[a..z]>+ '::/'};
    return "/type/$_" if m/^<[A..Z]>/;
    return "/routine/$_" if m/^<[a..z]>/;
    return $_;
}

my $*DEBUG = False;

my %names;
my %types;
my %routines;


sub pod-gist(Pod::Block $pod, $level = 0) {
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
        else {
            @chunks.push: $c.indent($level + 2), "\n";
        }
    }
    @chunks.join;
}

sub recursive-dir($dir) {
    my @todo = $dir;
    gather while @todo {
        my $d = @todo.shift;
        for dir($d) -> $f {
            if $f.f {
                take $f;
            }
            else {
                @todo.push($f.path);
            }
        }
    }
}

sub MAIN($out_dir = 'html', Bool :$debug) {
    $*DEBUG = $debug;
    for ('', <type language routine>) {
        mkdir "$out_dir/$_" unless "$out_dir/$_".IO ~~ :e;
    }

    my @source := recursive-dir('lib').grep(*.f).grep(rx{\.pod$});

    for (@source) {
        my $podname = .path.subst('lib/', '').subst(rx{\.pod$}, '').subst(:g, '/', '::');
        my $what = $podname ~~ /^<[A..Z]> | '::'/  ?? 'type' !! 'language';
        say "$_.path() => $what/$podname";
        %names{$podname}{$what}.push: "/$what/$podname";
        %types{$what}{$podname} =    "/$what/$podname";
        my $pod  = eval slurp(.path) ~ "\n\$=pod";
        spurt "$out_dir/$what/$podname.html", pod2html($pod, :url(&url-munge));
        next if $what eq 'language';
        $pod = $pod[0];

        say pod-gist($pod) if $*DEBUG;
        my @chunks = chunks-grep($pod.content,
                :from({ $_ ~~ Pod::Heading and .level == 2}),
                :to({ $^b ~~ Pod::Heading and $^b.level <= $^a.level}),
            );
        for @chunks -> $chunk {
            my $name = $chunk[0].content[0].content[0];
            say "$podname.$name" if $*DEBUG;
            next if $name ~~ /\s/;
            %names{$name}<routine>.push: "/type/$podname.html#" ~ uri_escape($name);
                %routines{$name}.push: $podname => $chunk;
            %types<routine>{$name} = "/routine/" ~ uri_escape( $name );
        }
    }
    write-search-file(:$out_dir);
    write-index-file(:$out_dir);
    say "Writing per-routine files...";
    for %routines.kv -> $name, @chunks {
        write-routine-file(:$out_dir, :$name, :@chunks);
        %routines.delete($name);
    }
    say "done writing per-routine files";
    # TODO: write top-level disambiguation files
}

sub chunks-grep(:$from!, :&to!, *@elems) {
    my @current;

    gather {
        for @elems -> $c {
            if @current && ($c ~~ $from || to(@current[0], $c)) {
                take [@current];
                @current = ();
                @current.push: $c if $c ~~ $from;
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
            @blocks.flat,
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

sub write-search-file(:$out_dir!) {
    say "Writing $out_dir/search.html";
    my $template = slurp("search_template.html");
    my @items;
    my sub fix-url ($raw) { $raw.substr(1) ~ '.html' };
    @items.push: %types<language>.pairs.sort.map({
        "\{ label: \"Language: {.key}\", value: \"{.key}\", url: \"{ fix-url(.value) }\" \}"
    });
    @items.push: %types<type>.sort.map({
        "\{ label: \"Type: {.key}\", value: \"{.key}\", url: \"{ fix-url(.value) }\" \}"
    });
    @items.push: %types<routine>.sort.map({
        "\{ label: \"Routine: {.key}\", value: \"{.key}\", url: \"{ fix-url(.value) }\" \}"
    });

    my $items = @items.join(",\n");
    spurt("$out_dir/search.html", $template.subst("ITEMS", $items));
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
    $file.print: pod2html($pod, :url(&url-munge));
    $file.close;
}

sub write-routine-file(:$name!, :$out_dir!, :@chunks!) {
    say "Writing $out_dir/routine/$name.html" if $*DEBUG;
    my $pod = pod-with-title("Documentation for routine $name",
        pod-block("Documentation for routine $name, assembled from the
            following types:"),
        @chunks.map(-> Pair (:key($type), :value($chunk)) {
            pod-heading($type),
            pod-block("From ", pod-link($type, "/type/{$type}#$name")),
            @$chunk
        })
    );
    my $file = open :w, "$out_dir/routine/$name.html";
    $file.print: pod2html($pod, :url(&url-munge));
    $file.close;
} 
