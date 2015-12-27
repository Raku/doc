#!/usr/bin/env perl6
use v6;
use MONKEY-SEE-NO-EVAL;

# This script isn't in bin/ because it's not meant to be installed.
# For syntax highlighting, needs pygmentize version 2.0 or newer installed
#
# for doc.perl6.org, the build process goes like this:
# * a cron job on hack.p6c.org as user 'doc.perl6.org' triggers the rebuild.
# It looks like this:
#
# */5 * * * * flock -n ~/update.lock -c ./doc/util/update-and-sync > update.log 2>&1
#
# util/update-and-sync is under version control in the perl6/doc repo (same as
# this file), and it first updates the git repository. If something changed, it
# run htmlify, captures the output, and on success, syncs both the generated
# files and the logs. In case of failure, only the logs are synchronized.
#
# The build logs are available at http://doc.perl6.org/build-log/
#

BEGIN say 'Initializing ...';

use Pod::To::HTML;
use URI::Escape;
use lib 'lib';
use Perl6::TypeGraph;
use Perl6::TypeGraph::Viz;
use Perl6::Documentable::Registry;
use Pod::Convenience;
use Pod::Htmlify;

use experimental :cached;

my $type-graph;
my %routines-by-type;
my %*POD2HTML-CALLBACKS;

# TODO: Generate menulist automatically
my @menu =
    ('language',''         ) => (),
    ('type', 'Types'       ) => <basic composite domain-specific exceptions>,
    ('routine', 'Routines' ) => <sub method term operator>,
#    ('module', 'Modules'   ) => (),
#    ('formalities',''      ) => ();
;

my $head   = slurp 'template/head.html';
sub header-html ($current-selection = 'nothing selected') is cached {
    state $header = slurp 'template/header.html';

    my $menu-items = [~]
        q[<div class="menu-items dark-green">],
        @menu>>.key.map(-> ($dir, $name) {qq[
            <a class="menu-item {$dir eq $current-selection ?? "selected darker-green" !! ""}"
                href="/$dir.html">
                { $name || $dir.wordcase }
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

    state $menu-pos = ($header ~~ /MENU/).from;
    $header.subst('MENU', :p($menu-pos), $menu-items ~ $sub-menu-items);
}

sub p2h($pod, $selection = 'nothing selected', :$pod-path = 'unknown') {
    pod2html $pod,
        :url(&url-munge),
        :$head,
        :header(header-html $selection),
        :footer(footer-html($pod-path)),
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
                @todo.append($f.path);
            }
        }
    }
}

# --sparse=5: only process 1/5th of the files
# mostly useful for performance optimizations, profiling etc.
sub MAIN(
    Bool :$typegraph = False,
    Int  :$sparse,
    Bool :$disambiguation = True,
    Bool :$search-file = True,
    Bool :$no-highlight = False,
    Bool :$no-inline-python = False,
) {
    say 'Creating html/ subdirectories ...';
    for flat '', <type language routine images syntax> {
        mkdir "html/$_" unless "html/$_".IO ~~ :e;
    }

    my $*DR = Perl6::Documentable::Registry.new;

    say 'Reading type graph ...';
    $type-graph = Perl6::TypeGraph.new-from-file('type-graph.txt');
    my %h = $type-graph.sorted.kv.flat.reverse;
    write-type-graph-images(:force($typegraph));

    process-pod-dir 'Language', :$sparse;
    process-pod-dir 'Type', :sorted-by{ %h{.key} // -1 }, :$sparse;

    highlight-code-blocks(:use-inline-python(!$no-inline-python)) unless $no-highlight;

    say 'Composing doc registry ...';
    $*DR.compose;

    for $*DR.lookup("language", :by<kind>).list -> $doc {
        say "Writing language document for {$doc.name} ...";
        my $pod-path = pod-path-from-url($doc.url);
        spurt "html{$doc.url}.html",
            p2h($doc.pod, 'language', pod-path => $pod-path);
    }
    for $*DR.lookup("type", :by<kind>).list {
        write-type-source $_;
    }

    write-disambiguation-files if $disambiguation;
    write-search-file          if $search-file;
    write-index-files;

    for (set(<routine syntax>) (&) set($*DR.get-kinds)).keys -> $kind {
        write-kind $kind;
    }

    say 'Processing complete.';
    if $sparse || !$search-file || !$disambiguation {
        say "This is a sparse or incomplete run. DO NOT SYNC WITH doc.perl6.org!";
    }
}

sub process-pod-dir($dir, :&sorted-by = &[cmp], :$sparse) {
    say "Reading doc/$dir ...";
    my @pod-sources =
        recursive-dir("doc/$dir/")
        .grep({.path ~~ / '.pod' $/})
        .map({
            .path.subst("doc/$dir/", '')
                 .subst(rx{\.pod$},  '')
                 .subst(:g,    '/',  '::')
            => $_
        }).sort(&sorted-by);
    if $sparse {
        @pod-sources = @pod-sources[^(@pod-sources / $sparse).ceiling];
    }

    say "Processing $dir Pod files ...";
    my $total = +@pod-sources;
    my $kind  = $dir.lc;
    for @pod-sources.kv -> $num, (:key($filename), :value($file)) {
        printf "% 4d/%d: % -40s => %s\n", $num+1, $total, $file.path, "$kind/$filename";
        my $pod  = EVAL(slurp($file.path) ~ "\n\$=pod")[0];
        process-pod-source :$kind, :$pod, :$filename, :pod-is-complete;
    }
}

sub process-pod-source(:$kind, :$pod, :$filename, :$pod-is-complete) {
    my $summary = '';
    my $name = $filename;
    my $first = $pod.contents[0];
    if $first ~~ Pod::Block::Named && $first.name eq "TITLE" {
        $name = $pod.contents[0].contents[0].contents[0];
        if $kind eq "type" {
            $name = $name.split(/\s+/)[*-1];
        }
    }
    else {
        note "$filename does not have a =TITLE";
    }
    if $pod.contents[1] ~~ {$_ ~~ Pod::Block::Named and .name eq "SUBTITLE"} {
        $summary = $pod.contents[1].contents[0].contents[0];
    }
    else {
        note "$filename does not have a =SUBTITLE";
    }

    my %type-info;
    if $kind eq "type" {
        if $type-graph.types{$name} -> $type {
            %type-info = :subkinds($type.packagetype), :categories($type.categories);
        }
        else {
            %type-info = :subkinds<class>;
        }
    }
    my $origin = $*DR.add-new(
        :$kind,
        :$name,
        :$pod,
        :url("/$kind/$filename"),
        :$summary,
        :$pod-is-complete,
        :subkinds($kind),
        |%type-info,
    );

    find-definitions :$pod, :$origin, :url("/$kind/$filename");
    find-references  :$pod, :$origin, :url("/$kind/$filename");
}

# XXX: Generalize
multi write-type-source($doc) {
    my $pod     = $doc.pod;
    my $podname = $doc.name;
    my $type    = $type-graph.types{$podname};
    my $what    = 'type';

    say "Writing $what document for $podname ...";

    if !$doc.pod-is-complete {
        $pod = pod-with-title("$doc.subkinds() $podname", $pod[1..*])
    }

    if $type {
        my $tg-preamble = qq[<h1>Type graph</h1>\n<p>Below you should see a
        clickable image showing the type relations for $podname that links
        to the documentation pages for the related types. If not, try the
        <a href="/images/type-graph-{uri_escape $podname}.png">PNG
        version</a> instead.</p>];
        $pod.contents.append: Pod::Raw.new(
            target => 'html',
            contents => $tg-preamble ~ svg-for-file("html/images/type-graph-$podname.svg"),

        );

        my @mro = $type.mro;
           @mro.shift; # current type is already taken care of

        my @roles-todo = $type.roles;
        my %roles-seen;
        while @roles-todo.shift -> $role {
            next unless %routines-by-type{$role};
            next if %roles-seen{$role}++;
            @roles-todo.append: $role.roles;
            $pod.contents.append:
                pod-heading("Routines supplied by role $role"),
                pod-block(
                    "$podname does role ",
                    pod-link($role.name, "/type/{uri_escape ~$role}"),
                    ", which provides the following methods:",
                ),
                %routines-by-type{$role}.list,
                ;
        }
        for @mro -> $class {
            next unless %routines-by-type{$class};
            $pod.contents.append:
                pod-heading("Routines supplied by class $class"),
                pod-block(
                    "$podname inherits from class ",
                    pod-link($class.name, "/type/{uri_escape ~$class}"),
                    ", which provides the following methods:",
                ),
                %routines-by-type{$class}.list,
                ;
            for $class.roles -> $role {
                next unless %routines-by-type{$role};
                $pod.contents.append:
                    pod-heading("Methods supplied by role $role"),
                    pod-block(
                        "$podname inherits from class ",
                        pod-link($class.name, "/type/{uri_escape ~$class}"),
                        ", which does role ",
                        pod-link($role.name, "/type/{uri_escape ~$role}"),
                        ", which provides the following methods:",
                    ),
                    %routines-by-type{$role}.list,
                    ;
            }
        }
    }
    else {
        note "Type $podname not found in type-graph data";
    }

    my $html-filename = "html" ~ $doc.url ~ ".html";
    my $pod-path = pod-path-from-url($doc.url);
    spurt $html-filename, p2h($pod, $what, pod-path => $pod-path);
}

sub find-references(:$pod!, :$url, :$origin) {
    if $pod ~~ Pod::FormattingCode && $pod.type eq 'X' {
        register-reference(:$pod, :$origin, :$url);
    }
    elsif $pod.?contents {
        for $pod.contents -> $sub-pod {
            find-references(:pod($sub-pod), :$url, :$origin) if $sub-pod ~~ Pod::Block;
        }
    }
}

sub register-reference(:$pod!, :$origin, :$url) {
    if $pod.meta {
        for @( $pod.meta ) -> $meta {
            my $name;
            if  $meta.elems > 1 {
                my $last = $meta[*-1];
                my $rest = $meta[0..*-2].join;
                $name = "$last ($rest)";
            }
            else {
                $name = $meta.Str;
            }
            $*DR.add-new(
                :$pod,
                :$origin,
                :$url,
                :kind<reference>,
                :subkinds['reference'],
                :$name,
            )
        }
    }
    elsif $pod.contents[0] -> $name {
        $*DR.add-new(
            :$pod,
            :$origin,
            :$url,
            :kind<reference>,
            :subkinds['reference'],
            :$name,
        )
    }
}

#| A one-pass-parser for pod headers that define something documentable.
sub find-definitions (:$pod, :$origin, :$min-level = -1, :$url) {
    # Runs through the pod content, and looks for headings.
    # If a heading is a definition, like "class FooBar", processes
    # the class and gives the rest of the pod to find-definitions,
    # which will return how far the definition of "class FooBar" extends.
    # We then continue parsing from after that point.
    my @pod-section := $pod ~~ Positional ?? @$pod !! $pod.contents;
    my int $i = 0;
    my int $len = +@pod-section;
    while $i < $len {
        NEXT {$i = $i + 1}
        my $pod-element := @pod-section[$i];
        next unless $pod-element ~~ Pod::Heading;
        return $i if $pod-element.level <= $min-level;

        # Is this new header a definition?
        # If so, begin processing it.
        # If not, skip to the next heading.
        
        my @header;
        try {
            @header := $pod-element.contents[0].contents;
            CATCH { next }
        }
        my @definitions; # [subkind, name]
        my $unambiguous = False;
        given @header {
            when :("", Pod::FormattingCode $, "") {
                my $fc := .[1];
                proceed unless $fc.type eq "X";
                @definitions = $fc.meta[0].flat;
                # set default name if none provide so X<if|control> gets name 'if'
                @definitions[1] = $fc.contents[0] if @definitions == 1;
                $unambiguous = True;
            }
            when :(Str $ where /^The \s \S+ \s \w+$/) {
                # The Foo Infix
                @definitions = .[0].words[2,1];
            }
            when :(Str $ where {m/^(\w+) \s (\S+)$/}) {
                # Infix Foo
                @definitions = .[0].words[0,1];
            }
            when :(Str $ where {m/^trait\s+(\S+\s\S+)$/}) {
                # Infix Foo
                @definitions = .split(/\s+/, 2)
            }
            when :("The ", Pod::FormattingCode $, Str $ where /^\s (\w+)$/) {
                # The C<Foo> infix
                @definitions = .[2].words[0], .[1].contents[0];
            }
            when :(Str $ where /^(\w+) \s$/, Pod::FormattingCode $, "") {
                # infix C<Foo>
                @definitions = .[0].words[0], .[1].contents[0];
            }
            default { next }
        }

        my int $new-i = $i;
        {
            my ( $sk, $name ) = @definitions;
            my $subkinds = $sk.lc;
            my %attr;
            given $subkinds {
                when / ^ [in | pre | post | circum | postcircum ] fix | listop / {
                    %attr = :kind<routine>,
                            :categories<operator>,
                }
                when 'sub'|'method'|'term'|'routine'|'trait' {
                    %attr = :kind<routine>,
                            :categories($subkinds),
                }
                when 'class'|'role'|'enum' {
                    my $summary = '';
                    if @pod-section[$i+1] ~~ {$_ ~~ Pod::Block::Named and .name eq "SUBTITLE"} {
                        $summary = @pod-section[$i+1].contents[0].contents[0];
                    }
                    else {
                        note "$name does not have an =SUBTITLE";
                    }
                    %attr = :kind<type>,
                            :categories($type-graph.types{$name}.?categories//''),
                            :$summary,
                }
                when 'variable'|'sigil'|'twigil'|'declarator'|'quote' {
                    # TODO: More types of syntactic features
                    %attr = :kind<syntax>,
                            :categories($subkinds),
                }
                when $unambiguous {
                    # Index anything from an X<>
                    %attr = :kind<syntax>,
                            :categories($subkinds),
                }
                default {
                    # No clue, probably not meant to be indexed
                    next;
                }
            }

            # We made it this far, so it's a valid definition
            my $created = $*DR.add-new(
                :$origin,
                :pod[],
                :!pod-is-complete,
                :$name,
                :$subkinds,
                |%attr
            );

            # Preform sub-parse, checking for definitions elsewhere in the pod
            # And updating $i to be after the places we've already searched
            once {
                $new-i = $i + find-definitions
                    :pod(@pod-section[$i+1..*]),
                    :origin($created),
                    :$url,
                    :min-level(@pod-section[$i].level);
            }

            my $new-head = Pod::Heading.new(
                :level(@pod-section[$i].level),
                :contents[pod-link "$subkinds $name",
                    $created.url ~ "#$origin.human-kind() $origin.name()".subst(:g, /\s+/, '_')
                ]
            );
            my @orig-chunk = flat $new-head, @pod-section[$i ^.. $new-i];
            my $chunk = $created.pod.append: pod-lower-headings(@orig-chunk, :to(%attr<kind> eq 'type' ?? 0 !! 2));

            if $subkinds eq 'routine' {
                # Determine proper subkinds
                my Str @subkinds = first-code-block($chunk)\
                    .match(:g, /:s ^ 'multi'? (sub|method)»/)\
                    .>>[0]>>.Str.unique;

                note "The subkinds of routine $created.name() in $origin.name() cannot be determined."
                    unless @subkinds;

                $created.subkinds   = @subkinds;
                $created.categories = @subkinds;
            }
            if %attr<kind> eq 'routine' {
                %routines-by-type{$origin.name}.append: $chunk;
                write-qualified-method-call(
                    :$name,
                    :pod($chunk),
                    :type($origin.name),
                );
            }
        }
        $i = $new-i + 1;
    }
    return $i;
}

sub write-type-graph-images(:$force) {
    unless $force {
        my $dest = 'html/images/type-graph-Any.svg'.IO;
        if $dest.e && $dest.modified >= 'type-graph.txt'.IO.modified {
            say "Not writing type graph images, it seems to be up-to-date";
            say "To force writing of type graph images, supply the --typegraph";
            say "option at the command line, or delete";
            say "file 'html/images/type-graph-Any.svg'";
            return;
        }
    }
    say 'Writing type graph images to html/images/ ...';
    for $type-graph.sorted -> $type {
        my $viz = Perl6::TypeGraph::Viz.new-for-type($type);
        $viz.to-file("html/images/type-graph-{$type}.svg", format => 'svg');
        $viz.to-file("html/images/type-graph-{$type}.png", format => 'png', size => '8,3');
        print '.'
    }
    say '';

    say 'Writing specialized visualizations to html/images/ ...';
    my %by-group = $type-graph.sorted.classify(&viz-group);
    %by-group<Exception>.append: $type-graph.types< Exception Any Mu >;
    %by-group<Metamodel>.append: $type-graph.types< Any Mu >;

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

sub write-search-file () {
    say 'Writing html/js/search.js ...';
    my $template = slurp("template/search_template.js");
    sub escape(Str $s) {
        $s.trans([</ \\ ">] => [<\\/ \\\\ \\">]);
    }
    my $items = $*DR.get-kinds.map(-> $kind {
        $*DR.lookup($kind, :by<kind>).categorize({escape .name})\
            .pairs.sort({.key}).map: -> (:key($name), :value(@docs)) {
                qq[[\{ category: "{
                    ( @docs > 1 ?? $kind !! @docs.[0].subkinds[0] ).wordcase
                }", value: "$name", url: "{@docs.[0].url}" \}]] #"
            }
    }).flat.join(",\n");
    spurt("html/js/search.js", $template.subst("ITEMS", $items));
}

sub write-disambiguation-files () {
    say 'Writing disambiguation files ...';
    for $*DR.grouped-by('name').kv -> $name, $p is copy {
        print '.';
        my $pod = pod-with-title("Disambiguation for '$name'");
        if $p.elems == 1 {
            $p = $p[0] if $p ~~ Array;
            if $p.origin -> $o {
                $pod.contents.append:
                    pod-block(
                        pod-link("'$name' is a $p.human-kind()", $p.url),
                        ' from ',
                        pod-link($o.human-kind() ~ ' ' ~ $o.name, $o.url),
                    );
            }
            else {
                $pod.contents.append:
                    pod-block(
                        pod-link("'$name' is a $p.human-kind()", $p.url)
                    );
            }
        }
        else {
            $pod.contents.append:
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
        spurt "html/$name.subst(/<[/\\]>/,'_',:g).html", $html;
    }
    say '';
}

sub write-index-files () {
    say 'Writing html/index.html ...';
    spurt 'html/index.html',
        p2h(EVAL(slurp('doc/HomePage.pod') ~ "\n\$=pod"),
            pod-path => 'HomePage.pod');

    say 'Writing html/language.html ...';
    spurt 'html/language.html', p2h(pod-with-title(
        'Perl 6 Language Documentation',
        pod-table($*DR.lookup('language', :by<kind>).sort(*.name).map({[
            pod-link(.name, .url),
            .summary
        ]}))
    ), 'language');

    my &summary;
    &summary = {
        .[0].subkinds[0] ne 'role' ?? .[0].summary !!
            Pod::FormattingCode.new(:type<I>, contents => [.[0].summary]);
    }

    write-main-index :kind<type> :&summary;

    for <basic composite domain-specific exceptions> -> $category {
        write-sub-index :kind<type> :$category :&summary;
    }

    &summary = {
        pod-block("(From ", $_>>.origin.map({
            pod-link(.name, .url)
        }).reduce({$^a,", ",$^b}),")")
    }

    write-main-index :kind<routine> :&summary;

    for <sub method term operator> -> $category {
        write-sub-index :kind<routine> :$category :&summary;
    }
}

sub write-main-index(:$kind, :&summary = {Nil}) {
    say "Writing html/$kind.html ...";
    spurt "html/$kind.html", p2h(pod-with-title(
        "Perl 6 {$kind.tc}s",
        pod-block(
            'This is a list of ', pod-bold('all'), ' built-in ' ~ $kind.tc ~
            "s that are documented here as part of the Perl 6 language. " ~
            "Use the above menu to narrow it down topically."
        ),
        pod-table($*DR.lookup($kind, :by<kind>)\
            .categorize(*.name).sort(*.key)>>.value
            .map({[
                .map({.subkinds // Nil}).unique.join(', '),
                pod-link(.[0].name, .[0].url),
                .&summary
            ]})
        )
    ), $kind);
}

# XXX: Only handles normal routines, not types nor operators
sub write-sub-index(:$kind, :$category, :&summary = {Nil}) {
    say "Writing html/$kind-$category.html ...";
    spurt "html/$kind-$category.html", p2h(pod-with-title(
        "Perl 6 {$category.tc} {$kind.tc}s",
        pod-table($*DR.lookup($kind, :by<kind>)\
            .grep({$category ⊆ .categories})\ # XXX
            .categorize(*.name).sort(*.key)>>.value
            .map({[
                .map({.subkinds // Nil}).unique.join(', '),
                pod-link(.[0].name, .[0].url),
                .&summary
            ]})
        )
    ), $kind);
}

sub write-kind($kind) {
    say "Writing per-$kind files ...";
    $*DR.lookup($kind, :by<kind>)
        .categorize({.name})
        .kv.map: -> $name, @docs {
            my @subkinds = @docs.map({.subkinds}).unique;
            my $subkind = @subkinds.elems == 1 ?? @subkinds.list[0] !! $kind;
            my $pod = pod-with-title(
                "Documentation for $subkind $name",
                pod-block("Documentation for $subkind $name, assembled from the following types:"),
                @docs.map({
                    pod-heading("{.origin.human-kind} {.origin.name}"),
                    pod-block("From ",
                        pod-link(.origin.name,
                            .origin.url ~ '#' ~ (.subkinds~'_' if .subkinds ~~ /fix/) ~ .name),
                    ),
                    .pod.list,
                })
            );
            print '.';
            spurt "html/$kind/$name.subst(/<[/\\]>/,'_',:g).html", p2h($pod, $kind);
        }
    say '';
}

sub write-qualified-method-call(:$name!, :$pod!, :$type!) {
    my $p = pod-with-title(
        "Documentation for method $type.$name",
        pod-block('From ', pod-link($type, "/type/{$type}#$name")),
        @$pod,
    );
    return if $name ~~ / '/' /;
    spurt "html/routine/{$type}.{$name}.html", p2h($p, 'routine');
}

sub highlight-code-blocks(:$use-inline-python = True) {
    my $pyg-version = try qx/pygmentize -V/;
    if $pyg-version && $pyg-version ~~ /^'Pygments version ' (\d\S+)/ {
        if Version.new(~$0) ~~ v2.0+ {
            say "pygmentize $0 found; code blocks will be highlighted";
        }
        else {
            say "pygmentize $0 is too old; need at least 2.0";
            return;
        }
    }
    else {
        say "pygmentize not found; code blocks will not be highlighted";
        return;
    }

    my $py = $use-inline-python && try {
        require Inline::Python;
        my $inline-py = ::('Inline::Python').new();
        $inline-py.run(q{
import pygments.lexers
import pygments.formatters
p6lexer = pygments.lexers.get_lexer_by_name("perl6")
htmlformatter = pygments.formatters.get_formatter_by_name("html")

def p6format(code):
    return pygments.highlight(code, p6lexer, htmlformatter)
});
        $inline-py;
    }
    if $py {
        say "Using syntax highlighting via Inline::Python";
    }

    %*POD2HTML-CALLBACKS = code => sub (:$node, :&default) {
        for @($node.contents) -> $c {
            if $c !~~ Str {
                # some nested formatting code => we can't highlight this
                return default($node);
            }
        }
        if $py {
            return $py.call('__main__', 'p6format', $node.contents.join);
        }
        else {
            my $basename = join '-', %*ENV<USER> // 'u', (^100_000).pick, 'pod_to_pyg.pod';
            my $tmp_fname = "$*TMPDIR/$basename";
            spurt $tmp_fname, $node.contents.join;
            LEAVE try unlink $tmp_fname;
            my $command = "pygmentize -l perl6 -f html < $tmp_fname";
            return qqx{$command};

        }
    }
}

#| Determine path to source POD from the POD object's url attribute
sub pod-path-from-url($url) {
    my $pod-path = $url.subst('::', '/', :g) ~ '.pod';
    $pod-path.subst-mutate(/^\//, '');  # trim leading slash from path
    $pod-path = $pod-path.tc;

    return $pod-path;
}

# vim: expandtab shiftwidth=4 ft=perl6
