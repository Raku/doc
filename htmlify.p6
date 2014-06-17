#!/usr/bin/env perl6
use v6;

# This script isn't in bin/ because it's not meant to be installed.

BEGIN say 'Initializing ...';

use Pod::To::HTML;
use URI::Escape;
use lib 'lib';
use Perl6::TypeGraph;
use Perl6::TypeGraph::Viz;
use Perl6::Documentable::Registry;

my $*DEBUG = False;

my $tg;
my %methods-by-type;

sub url-munge($_) {
    return $_ if m{^ <[a..z]>+ '://'};
    return "/type/{uri_escape $_}" if m/^<[A..Z]>/;
    return "/routine/{uri_escape $_}" if m/^<[a..z]>/;
    # poor man's <identifier>
    if m/ ^ '&'( \w <[[\w'-]>* ) $/ {
        return "/routine/{uri_escape $0}";
    }
    return $_;
}

# TODO: Generate menulist automatically
my @menu =
    ('language',''         ) => (),
    ('type', 'Types'       ) => <basic composite domain-specific exception>,
    ('routine', 'Routines' ) => <sub method term operator>,
    ('module', 'Modules'   ) => (),
    ('formalities',''      ) => ();
        
my $head   = slurp 'template/head.html';
my $footer = footer-html;
sub header-html ($current-selection = 'nothing selected') is cached {
    state $header = slurp 'template/header.html';

    my $menu-items = [~]
        q[<div class="menu-items dark-green">],
        @menu>>.key.map({qq[
            <a class="menu-item {.[0] eq $current-selection ?? "selected darker-green" !! ""}"
                href="/{.[0]}">
                { .[1] || .[0].wordcase }
            </a>
        ]}), #"
        q[</div>];

    my $sub-menu-items = '';
    state %sub-menus = @menu>>.key>>[0] Z=> @menu>>.value;
    if %sub-menus{$current-selection} -> $_ {
        $sub-menu-items = [~] 
            q[<div class="menu-items darker-green">],
            .map({qq[
                <a class="menu-item" href="/$current-selection\-$_">
                    {.wordcase}
                </a>
            ]}),
            q[</div>]
    }

    $header.subst('MENU', qq[
        <div class="menu">
        $menu-items
        $sub-menu-items
        </div>
    ])

}

sub p2h($pod, $selection = 'nothing selected') {
    pod2html($pod, :url(&url-munge), :$head, :header(header-html $selection), :$footer);
}

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

sub first-code-block(@pod) {
    if @pod[1] ~~ Pod::Block::Code {
        return @pod[1].content.grep(Str).join;
    }
    '';
}

sub MAIN(Bool :$debug, Bool :$typegraph = False) {
    $*DEBUG = $debug;

    say 'Creating html/ subdirectories ...';
    for '', <type language routine images> {
        mkdir "html/$_" unless "html/$_".IO ~~ :e;
    }

    my $dr = Perl6::Documentable::Registry.new;

    say 'Reading type graph ...';
    $tg = Perl6::TypeGraph.new-from-file('type-graph.txt');
    my %h = $tg.sorted.kv.flat.reverse;

    process-pod-dir 'Language', :$dr;
    process-pod-dir 'Type', :$dr :sorted-by{ %h{.key} // -1 };

    say 'Composing doc registry ...';
    $dr.compose;

    write-disambiguation-files($dr);
    write-type-graph-images(:force($typegraph));
    write-search-file($dr);
    write-index-files($dr);

    say 'Writing per-routine files ...';
    my %routine-seen;
    for $dr.lookup('routine', :by<kind>).list -> $d {
        next if %routine-seen{$d.name}++;
        write-routine-file($dr, $d.name);
        print '.'
    }
    say '';

    say 'Processing complete.';
}

sub process-pod-dir($dir, :$dr, :&sorted-by = &[cmp]) {
    say "Reading lib/$dir ...";
    my @pod-sources =
        recursive-dir("lib/$dir/")\
        .map({;
            .path.subst("lib/$dir/", '')\
                 .subst(rx{\.pod$},  '')\
                 .subst(:g,    '/',  '::')
            => $_
        }).sort(&sorted-by);

    say "Processing $dir Pod files ...";
    my $total = +@pod-sources;
    my $what  = $dir.lc;
    for @pod-sources.kv -> $num, (:key($podname), :value($file)) {
        printf "% 4d/%d: % -40s => %s\n", $num, $total, $file.path, "$what/$podname";
        my $pod  = EVAL(slurp($file.path) ~ "\n\$=pod")[0];
        process-pod-file($what, :$dr, :what($what), :$pod, :$podname);
    }
}

multi process-pod-file("language", :$dr, :$what, :$pod, :$podname) {
    spurt "html/$what/$podname.html", p2h($pod, $what);
    my $name = $pod.content[0].name eq "TITLE"
            ?? $pod.content[0].content[0].content[0]
            !! $podname;
    my $d = $dr.add-new(
                :kind<language>,
                :name($name),
                :url("/language/$podname"),
                :$pod,
                :pod-is-complete,
               );
    if $podname eq 'operators' {
        my @chunks = chunks-grep($pod.content,
                                 :from({ $_ ~~ Pod::Heading and .level == 2}),
                                 :to({  $^b ~~ Pod::Heading and $^b.level <= $^a.level}),
                                );
        for @chunks -> $chunk {
            my $heading = $chunk[0].content[0].content[0];
            next unless $heading ~~ / ^ [in | pre | post | circum | postcircum ] fix | listop /;
            my $what = ~$/;
            my $operator = $heading.split(' ', 2)[1];
            $dr.add-new(
                        :kind<routine>,
                        :subkinds($what),
                        :categories<operator>,
                        :name($operator),
                        :pod($chunk),
                        :origin($d)
                        :!pod-is-complete,
                       );
        }
    }
}

multi process-pod-file("type", :$dr, :$what, :$pod, :$podname) {
    my @chunks = chunks-grep($pod.content,
                             :from({ $_ ~~ Pod::Heading and .level == 2}),
                             :to({  $^b ~~ Pod::Heading and $^b.level <= $^a.level}),
                            );

    my $subkind = 'class';
    if $tg.types{$podname} -> $t {
        $subkind = $t.packagetype;
        $pod.content.push: Pod::Block::Named.new(
            name    => 'Image',
            content => [ "/images/type-graph-$podname.png"],
        );
        $pod.content.push: pod-link(
            'Full-size type graph image as SVG',
            "/images/type-graph-$podname.svg",
        );

        my @mro = $t.mro;
           @mro.shift; # current type is already taken care of

        for $t.roles -> $r {
            next unless %methods-by-type{$r};
            $pod.content.push:
                pod-heading("Methods supplied by role $r"),
                pod-block(
                    "$podname does role ",
                    pod-link($r.name, "/type/$r"),
                    ", which provides the following methods:",
                ),
                %methods-by-type{$r}.list,
                ;
        }
        for @mro -> $c {
            next unless %methods-by-type{$c};
            $pod.content.push:
                pod-heading("Methods supplied by class $c"),
                pod-block(
                    "$podname inherits from class ",
                    pod-link($c.name, "/type/$c"),
                    ", which provides the following methods:",
                ),
                %methods-by-type{$c}.list,
                ;
            for $c.roles -> $r {
                next unless %methods-by-type{$r};
                $pod.content.push:
                    pod-heading("Methods supplied by role $r"),
                    pod-block(
                        "$podname inherits from class ",
                        pod-link($c.name, "/type/$c"),
                        ", which does role ",
                        pod-link($r.name, "/type/$r"),
                        ", which provides the following methods:",
                    ),
                    %methods-by-type{$r}.list,
                    ;
            }
        }
    }
    my $d = $dr.add-new(
        :kind<type>,
        :subkinds($subkind),
        :$pod,
        :pod-is-complete,
        :name($podname),
    );

    for @chunks -> $chunk {
        my $name = $chunk[0].content[0].content[0];
        say "$podname.$name" if $*DEBUG;
        %methods-by-type{$podname}.push: $chunk;
        # check if it's an operator
        if $name ~~ /\s/ {
            next unless $name ~~ / ^ [in | pre | post | circum | postcircum ] fix | listop /;
            my $what = ~$/;
            my $operator = $name.split(' ', 2)[1];
            $dr.add-new(
                        :kind<routine>,
                        :subkinds($what),
                        :categories<operator>,
                        :name($operator),
                        :pod($chunk),
                        :!pod-is-complete,
                        :origin($d),
            );
        } else {
            # determine whether it's a sub or method
            my Str @subkinds;
            {
                my %counter;
                for first-code-block($chunk).lines {
                    if ms/^ 'multi'? (sub|method)»/ {
                        %counter{$0}++;
                    }
                }
                if +%counter {
                    @subkinds = %counter.keys;
                } else {
                    note "The subkinds of routine $name in $podname.pod cannot be determined."
                }
                if %counter<method> {
                    write-qualified-method-call(
                        :$name,
                        :pod($chunk),
                        :type($podname),
                    );
                }
            }

            $dr.add-new(
                :kind<routine>,
                :@subkinds,
                :categories(@subkinds),
                :$name,
                :pod($chunk),
                :!pod-is-complete,
                :origin($d),
            );
        }
    }

    spurt "html/$what/$podname.html", p2h($pod, $what);
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
        content => [$text],
        meta    => [$url],
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

sub pod-table(@content) {
    Pod::Block::Table.new(
        :@content
    )
}

sub write-type-graph-images(:$force) {
    unless $force {
        my $dest = 'html/images/type-graph-Any.svg'.path;
        if $dest.e && $dest.modified >= 'type-graph.txt'.path.modified {
            say "Not writing type graph images, it seems to be up-to-date";
            say "To force writing of type graph images, supply the --typegraph";
            say "option at the command line, or delete";
            say "file 'html/images/type-graph-Any.svg'";
            return;
        }
    }
    say 'Writing type graph images to html/images/ ...';
    for $tg.sorted -> $type {
        my $viz = Perl6::TypeGraph::Viz.new-for-type($type);
        $viz.to-file("html/images/type-graph-{$type}.svg", format => 'svg');
        $viz.to-file("html/images/type-graph-{$type}.png", format => 'png', size => '8,3');
        print '.'
    }
    say '';

    say 'Writing specialized visualizations to html/images/ ...';
    my %by-group = $tg.sorted.classify(&viz-group);
    %by-group<Exception>.push: $tg.types< Exception Any Mu >;
    %by-group<Metamodel>.push: $tg.types< Any Mu >;

    for %by-group.kv -> $group, @types {
        my $viz = Perl6::TypeGraph::Viz.new(:types(@types),
                                            :dot-hints(viz-hints($group)),
                                            :rank-dir('LR'));
        $viz.to-file("html/images/type-graph-{$group}.svg", format => 'svg');
        $viz.to-file("html/images/type-graph-{$group}.png", format => 'png', size => '8,3');
    }
}

sub viz-group ($type) {
    return 'Metamodel' if $type.name ~~ /^ 'Perl6::Metamodel' /;
    return 'Exception' if $type.name ~~ /^ 'X::' /;
    return 'Any';
}

sub viz-hints ($group) {
    return '' unless $group eq 'Any';

    return '
    subgraph "cluster: Mu children" {
        rank=same;
        style=invis;
        "Any";
        "Junction";
    }
    subgraph "cluster: Pod:: top level" {
        rank=same;
        style=invis;
        "Pod::Config";
        "Pod::Block";
    }
    subgraph "cluster: Date/time handling" {
        rank=same;
        style=invis;
        "Date";
        "DateTime";
        "DateTime-local-timezone";
    }
    subgraph "cluster: Collection roles" {
        rank=same;
        style=invis;
        "Positional";
        "Associative";
        "Baggy";
    }
';
}

sub write-search-file($dr) {
    say 'Writing html/js/search.js ...';
    my $template = slurp("template/search_template.js");
    my @items;
    my sub fix-url ($raw) {
        $raw #~~ /^.(.*?)('#'.*)?$/;
        #$0 ~ '.html' ~ ($1||'')
    };
    sub escape(Str $s) {
        $s.trans([</ \\ ">] => [<\\/ \\\\ \\">]);
    }
    @items.push: $dr.lookup('language', :by<kind>).sort(*.name).map({
        qq[\{ label: "Language: {.name}", value: "{.name}", url: "{ fix-url(.url) }" \}]
    });
    @items.push: $dr.lookup('type', :by<kind>).sort(*.name).map({
        qq[\{ label: "Type: {.name}", value: "{.name}", url: "{ fix-url(.url) }" \}]
    });
    my %seen;
    @items.push: $dr.lookup('routine', :by<kind>).grep({!%seen{.name}++}).sort(*.name).map({
        do for .subkinds // 'Routine' -> $subkind {
            qq[\{ label: "{ $subkind.tclc }: {escape .name}", value: "{escape .name}", url: "{ fix-url(.url) }" \}]
        }
    });

    my $items = @items.join(",\n");
    spurt("html/js/search.js", $template.subst("ITEMS", $items));
}

sub write-disambiguation-files($dr) {
    say 'Writing disambiguation files ...';
    for $dr.grouped-by('name').kv -> $name, $p is copy {
        print '.';
        my $pod = pod-with-title("Disambiguation for '$name'");
        if $p.elems == 1 {
            $p = $p[0] if $p ~~ Array;
            if $p.origin -> $o {
                $pod.content.push:
                    pod-block(
                        pod-link("'$name' is a $p.human-kind()", $p.url),
                        ' from ',
                        pod-link($o.human-kind() ~ ' ' ~ $o.name, $o.url),
                    );
            }
            else {
                $pod.content.push:
                    pod-block(
                        pod-link("'$name' is a $p.human-kind()", $p.url)
                    );
            }
        }
        else {
            $pod.content.push:
                pod-block("'$name' can be anything of the following"),
                $p.map({
                    if .origin -> $o {
                        pod-item(
                            pod-link(.human-kind, .url),
                            ' from ',
                            pod-link($o.human-kind() ~ ' ' ~ $o.name, $o.url),
                        )
                    }
                    else {
                        pod-item( pod-link(.human-kind, .url) )
                    }
                });
        }
        my $html = p2h($pod, 'routine');
        spurt "html/$name.html", $html;
    }
    say '';
}

sub write-index-files($dr) {
    # XXX: Main index file can't be generated properly until
    # it is turned into a Pod file. For now, it's just static.
    #say 'Writing html/index.html ...';
    #spurt 'html/index.html', p2h slurp('template/index-content.html');

    say 'Writing html/language.html ...';
    spurt 'html/language.html', p2h(pod-with-title(
        'Perl 6 Language Documentation',
        $dr.lookup('language', :by<kind>).sort(*.name).map({
            pod-item( pod-link(.name, .url) )
        })
    ), 'language');

    sub list-of-all($what) {
        pod-block 'This is a list of ', Pod::FormattingCode.new(:type<B>:content['all']),
            " built-in {$what}s that are documented here as part of the the Perl 6 language. ",
            "Use the above menu to narrow it down topically."
    }

    sub write-main-index($kind) {
        say "Writing html/$kind.html ...";
        spurt "html/$kind.html", p2h(pod-with-title(
            "Perl 6 {$kind.tc}s",
            list-of-all($kind),
            pod-table($dr.lookup($kind, :by<kind>).categorize(*.name).sort(*.key)>>.value.map({
                [set(.map: {.subkinds // Nil}).list.join(', '), pod-link(.[0].name, .[0].url), .[0].summary]
            }))
        ), $kind);
    }

    # XXX: Only handles normal routines, not types nor operators
    sub write-sub-index($kind, $category) {
        say "Writing html/$kind-$category.html ...";
        spurt "html/$kind-$category.html", p2h(pod-with-title(
            "Perl 6 {$category.tc} {$kind.tc}s",
            pod-table($dr.lookup($kind, :by<kind>)\
                .grep({$category ⊆ .categories})\ # XXX
                .categorize(*.name).sort(*.key)>>.value\
                .map({
                    [set(.map: {.subkinds // Nil}).list.join(', '), pod-link(.[0].name, .[0].url), .[0].summary]
                })
            )
        ), $kind);
    }

    .&write-main-index for <type routine>;
    write-sub-index 'routine', $_ for <sub method term operator>;
}

sub write-routine-file($dr, $name) {
    say 'Writing html/routine/$name.html ...' if $*DEBUG;
    my @docs = $dr.lookup($name, :by<name>).grep(*.kind eq 'routine');
    my $subkind = 'routine';
    {
        my @subkinds = @docs>>.subkinds;
        $subkind = @subkinds[0] if all(@subkinds>>.defined) && [eq] @subkinds;
    }
    my $pod = pod-with-title("Documentation for $subkind $name",
        pod-block("Documentation for $subkind $name, assembled from the
            following types:"),
        @docs.map({
            pod-heading("{.human-kind} {.name} defined in {.origin.human-kind} {.origin.name}"),
            pod-block("From ", pod-link(.origin.name, .origin.url ~ '#' ~ (.subkinds~'_' if .subkinds ~~ /fix/) ~ .name)),
            .pod.list,
        })
    );
    spurt "html/routine/$name.html", p2h($pod, 'routine');
}

sub write-qualified-method-call(:$name!, :$pod!, :$type!) {
    my $p = pod-with-title(
        "Documentation for method $type.$name",
        pod-block('From ', pod-link($type, "/type/{$type}#$name")),
        @$pod,
    );
    spurt "html/routine/{$type}.{$name}.html", p2h($p, 'routine');
}

sub footer-html() {
    state $dt = ~DateTime.now;
    my $footer = slurp 'template/footer_template.html';
    my $footer_content = qq[
        <p>
            Generated on $dt from the sources at
            <a href="https://github.com/perl6/doc">perl6/doc on github</a>.
            This is a work in progress to document Perl 6, and known to be
            incomplete. Your contribution is appreciated.
        </p>
        <p>
            The Camelia image is copyright 2009 by Larry Wall.
        </p>
    ];
    $footer.subst('CONTENT', $footer_content);
}
