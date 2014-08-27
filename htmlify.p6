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
use Pod::Convenience;

my $*DEBUG = False;

my $tg;
my %methods-by-type;

sub url-munge($_) {
    return $_ if m{^ <[a..z]>+ '://'};
    return "/type/{uri_escape $_}" if m/^<[A..Z]>/;
    return "/routine/{uri_escape $_}" if m/^<[a..z]>|^<-alpha>*$/;
    # poor man's <identifier>
    if m/ ^ '&'( \w <[[\w'-]>* ) $/ {
        return "/routine/{uri_escape $0}";
    }
    return $_;
}

# TODO: Generate menulist automatically
my @menu =
    ('language',''         ) => (),
    ('type', 'Types'       ) => <basic composite domain-specific exceptions>,
    ('routine', 'Routines' ) => <sub method term operator>,
#    ('module', 'Modules'   ) => (),
#    ('formalities',''      ) => ();
;
        
my $head   = slurp 'template/head.html';
my $footer = footer-html;
sub header-html ($current-selection = 'nothing selected') is cached {
    state $header = slurp 'template/header.html';

    my $menu-items = [~]
        q[<div class="menu-items dark-green">],
        @menu>>.key.map({qq[
            <a class="menu-item {.[0] eq $current-selection ?? "selected darker-green" !! ""}"
                href="/{.[0]}.html">
                { .[1] || .[0].wordcase }
            </a>
        ]}), #"
        q[</div>];

    my $sub-menu-items = '';
    state %sub-menus = @menu>>.key>>[0] Z=> @menu>>.value;
    if %sub-menus{$current-selection} -> $_ {
        $sub-menu-items = [~] 
            q[<div class="menu-items darker-green">],
            qq[<a class="menu-item" href="/$current-selection.html">All</a>],
            .map({qq[
                <a class="menu-item" href="/$current-selection\-$_.html">
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
    pod2html $pod,
        :url(&url-munge),
        :$head,
        :header(header-html $selection),
        :$footer,
        :default-title("Perl 6 Documentation"),
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

sub svg-for-file($file) {
    my $handle = open $file;
    my $str = join "\n", grep { /^'<svg'/ ff False }, $handle.lines;
    $handle.close;
    $str;
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
    write-type-graph-images(:force($typegraph));
    # XXX: Generalize
    process-pod-dir 'Type', :$dr :sorted-by{ %h{.key} // -1 };
    for $dr.lookup("type", :by<kind>).list {
        write-type-source $_;
    }

    say 'Composing doc registry ...';
    $dr.compose;

    write-disambiguation-files($dr);
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
        .grep({.path ~~ / '.pod' $/})\
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
        printf "% 4d/%d: % -40s => %s\n", $num+1, $total, $file.path, "$what/$podname";
        my $pod  = EVAL(slurp($file.path) ~ "\n\$=pod")[0];
        process-pod-source :$dr, :$what, :$pod, :$podname, :pod-is-complete;
    }
}

multi process-pod-source(:$what where "language", :$dr, :$pod, :$podname, :$pod-is-complete) {
    my $name = $podname;
    my $summary = '';
    if $pod.contents[0] ~~ {$_ ~~ Pod::Block::Named and .name eq "TITLE"} {
        $name = $pod.contents[0].contents[0].contents[0]
    } else {
        note "$podname does not have an =TITLE";
    }
    if $pod.contents[1] ~~ {$_ ~~ Pod::Block::Named and .name eq "SUBTITLE"} {
        $summary = $pod.contents[1].contents[0].contents[0];
    } else {
        note "$podname does not have an =SUBTITLE";
    }
    my $origin = $dr.add-new(
        :kind<language>,
        :name($name),
        :url("/language/$podname"),
        :$summary,
        :$pod,
        :pod-is-complete,
    );
    find-definitions :$dr, :$pod, :$origin;
    spurt "html/$what/$podname.html", p2h($pod, $what);
}

multi process-pod-source(:$what where "type", :$dr, :$pod, :$podname, :$pod-is-complete) {
    my $type = $tg.types{$podname};
    my $origin = $dr.add-new(
        :kind<type>,
        :subkinds($type ?? $type.packagetype !! 'class'),
        :categories($type ?? $type.categories !! Nil),
        :$pod,
        :$pod-is-complete,
        :name($podname),
    );

    find-definitions :$dr, :$pod, :$origin;
}

# XXX: Generalize
multi write-type-source($doc) {
    my $pod     = $doc.pod;
    my $podname = $doc.name;
    my $type    = $tg.types{$podname};
    my $what    = 'type';

    say "Writing $what document for $podname ...";

    if !$doc.pod-is-complete {
        $pod = pod-with-title("$doc.subkinds() $podname", $pod[1..*])
    }

    if $type {
        my $tg-preamble = qq[<h1>Type graph</h1>\n<p>Below you should see
        an imgage showing the type relations for $podname. If not, try the <a
        href="/images/type-graph-{uri_escape $podname}.png">PNG
        version</a>.</p>];
        $pod.contents.push: Pod::Raw.new(
            target => 'html',
            contents => $tg-preamble ~ svg-for-file("html/images/type-graph-$podname.svg"),

        );

        my @mro = $type.mro;
           @mro.shift; # current type is already taken care of

        for $type.roles -> $r {
            next unless %methods-by-type{$r};
            $pod.contents.push:
                pod-heading("Methods supplied by role $r"),
                pod-block(
                    "$podname does role ",
                    pod-link($r.name, "/type/{uri_escape ~$r}"),
                    ", which provides the following methods:",
                ),
                %methods-by-type{$r}.list,
                ;
        }
        for @mro -> $c {
            next unless %methods-by-type{$c};
            $pod.contents.push:
                pod-heading("Methods supplied by class $c"),
                pod-block(
                    "$podname inherits from class ",
                    pod-link($c.name, "/type/{uri_escape ~$c}"),
                    ", which provides the following methods:",
                ),
                %methods-by-type{$c}.list,
                ;
            for $c.roles -> $r {
                next unless %methods-by-type{$r};
                $pod.contents.push:
                    pod-heading("Methods supplied by role $r"),
                    pod-block(
                        "$podname inherits from class ",
                        pod-link($c.name, "/type/{uri_escape ~$c}"),
                        ", which does role ",
                        pod-link($r.name, "/type/{uri_escape ~$r}"),
                        ", which provides the following methods:",
                    ),
                    %methods-by-type{$r}.list,
                    ;
            }
        }
    } else {
        note "Type $podname not found in type-graph data";
    }

    spurt "html/$what/$podname.html", p2h($pod, $what);
}

sub find-definitions (:$pod, :$origin, :$dr, :$min-level = -1) {
    # Run through the pod content, and look for headings.
    # If a heading is a definition, like "class FooBar", process
    # the class and give the rest of the pod to find-definitions,
    # which will return how far the definition of "class FooBar" extends.
    my @c := $pod ~~ Positional ?? @$pod !! $pod.contents;
    my int $i = 0;
    my int $len = +@c;
    while $i < $len {
        my $c := @c[$i];
        if $c ~~ Pod::Heading {
            return $i if $c.level <= $min-level;

            # Is this new header a definition?
            # If so, begin processing it.
            # If not, skip to the next heading.
            $i = $i + 1 and next unless $c.contents[0].contents[0] ~~ Str
                                    and 2 == my @words = $c.contents[0].contents[0].words;

            my ($subkinds, $name) = @words;
            my %attr;
            given $subkinds {
                when / ^ [in | pre | post | circum | postcircum ] fix | listop / {
                    %attr = :kind<routine>,
                            :categories<operator>,
                }
                when 'sub'|'method'|'term'|'routine' {
                    %attr = :kind<routine>,
                            :categories($subkinds),
                }
                when 'class'|'role' {
                    %attr = :kind<type>,
                            :categories($tg.types{$name}.?categories//''),
                }
                default {
                    $i = $i + 1 and next
                }
            }
            # We made it this far, so it's a valid definition
            my $created = $dr.add-new(
                :$origin,
                :pod[],
                :!pod-is-complete,
                :$name,
                :$subkinds,
                |%attr
            );

            # Preform sub-parse, checking for definitions elsewhere in the pod
            # And updating $i to be after the places we've already searched
            my int $new-i = $i + find-definitions :pod(@c[$i+1..*]), :origin($created), :$dr, :min-level(@c[$i].level);

            @c[$i].contents[0] = pod-link "$subkinds $name",
                $created.url ~ "#$origin.human-kind() $origin.name()".subst(:g, /\s+/, '_');

            my $chunk = $created.pod.push: pod-lower-headings(@c[$i..$new-i], :to(%attr<kind> eq 'type' ?? 0 !! 2));

            $i = $new-i;
            
            if $subkinds eq 'routine' {
                # Determine proper subkinds
                my Str @subkinds = first-code-block($chunk)\
                    .match(:g, /:s ^ 'multi'? (sub|method)»/)\
                    .>>[0]>>.Str.uniq;

                note "The subkinds of routine $created.name() in $origin.name() cannot be determined."
                    unless @subkinds;

                $created.subkinds   = @subkinds;
                $created.categories = @subkinds;
            }
            if $subkinds ∋ 'method' {
                %methods-by-type{$origin.name}.push: $chunk;
                write-qualified-method-call(
                    :$name,
                    :pod($chunk),
                    :type($origin.name),
                );
            }
        }
        $i = $i + 1;
    }
    return $i;
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
                $pod.contents.push:
                    pod-block(
                        pod-link("'$name' is a $p.human-kind()", $p.url),
                        ' from ',
                        pod-link($o.human-kind() ~ ' ' ~ $o.name, $o.url),
                    );
            }
            else {
                $pod.contents.push:
                    pod-block(
                        pod-link("'$name' is a $p.human-kind()", $p.url)
                    );
            }
        }
        else {
            $pod.contents.push:
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
    say 'Writing html/index.html ...';
    spurt 'html/index.html', p2h EVAL slurp('lib/HomePage.pod') ~ "\n\$=pod";

    say 'Writing html/language.html ...';
    spurt 'html/language.html', p2h(pod-with-title(
        'Perl 6 Language Documentation',
        pod-table($dr.lookup('language', :by<kind>).sort(*.name).map({[
            pod-link(.name, .url),
            .summary
        ]}))
    ), 'language');

    write-main-index :$dr :kind<type>;

    for <basic composite domain-specific exceptions> -> $category {
        write-sub-index :$dr :kind<type> :$category;
    }

    my &summary = { 
        pod-block("(From ", $_>>.origin.map({
            pod-link(.name, .url)
        }).reduce({$^a,", ",$^b}),")")
    }

    write-main-index :$dr :kind<routine> :&summary;

    for <sub method term operator> -> $category {
        write-sub-index :$dr :kind<routine> :$category :&summary;
    }
}

sub write-main-index(:$dr, :$kind, :&summary = {Nil}) {
    say "Writing html/$kind.html ...";
    spurt "html/$kind.html", p2h(pod-with-title(
        "Perl 6 {$kind.tc}s",
        pod-block(
            'This is a list of ', pod-bold('all'), ' built-in ' ~ $kind.tc ~
            "s that are documented here as part of the Perl 6 language. " ~
            "Use the above menu to narrow it down topically."
        ),
        pod-table($dr.lookup($kind, :by<kind>)\
            .categorize(*.name).sort(*.key)>>.value\
            .map({[
                .map({.subkinds // Nil}).uniq.join(', '),
                pod-link(.[0].name, .[0].url),
                .&summary
            ]})
        )
    ), $kind);
}

# XXX: Only handles normal routines, not types nor operators
sub write-sub-index(:$dr, :$kind, :$category, :&summary = {Nil}) {
    say "Writing html/$kind-$category.html ...";
    spurt "html/$kind-$category.html", p2h(pod-with-title(
        "Perl 6 {$category.tc} {$kind.tc}s",
        pod-table($dr.lookup($kind, :by<kind>)\
            .grep({$category ⊆ .categories})\ # XXX
            .categorize(*.name).sort(*.key)>>.value\
            .map({[
                .map({.subkinds // Nil}).uniq.join(', '),
                pod-link(.[0].name, .[0].url),
                .&summary
            ]})
        )
    ), $kind);
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
            pod-heading("{.origin.human-kind} {.origin.name}"),
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
