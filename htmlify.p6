#!/usr/bin/env perl6
use v6;

=begin overview

This script isn't in bin/ because it's not meant to be installed.
For syntax highlighting, needs node.js installed.
Please run C<make init-highlights> to automatically pull in the highlighting
grammar and build the highlighter.

For doc.perl6.org, the build process goes like this:
a cron job on hack.p6c.org as user 'doc.perl6.org' triggers the rebuild.

    */5 * * * * flock -n ~/update.lock -c ./doc/util/update-and-sync > update.log 2>&1

C<util/update-and-sync> is under version control in the perl6/doc repo (same as
this file), and it first updates the git repository. If something changed, it
runs htmlify, captures the output, and on success, syncs both the generated
files and the logs. In case of failure, only the logs are synchronized.

The build logs are available at https://docs.perl6.org/build-log/

=end overview

BEGIN say 'Initializing ...';

use lib 'lib';
use JSON::Fast;
use Pod::To::HTML;
use URI::Escape;

use Perl6::Documentable::Registry;
use Perl6::TypeGraph;
use Perl6::TypeGraph::Viz;
use Pod::Convenience;
use Pod::Htmlify;
use OO::Monitors;
# Don't include backslash in Win or forwardslash on Unix because they are used
# as directory seperators. These are handled in lib/Pod/Htmlify.pm6
my \badchars-ntfs = Qw[ / ? < > : * | " ¥ ];
my \badchars-unix = Qw[ ];
my \badchars = $*DISTRO.is-win ?? badchars-ntfs !! badchars-unix;
{
    my monitor PathChecker {
        has %!seen-paths;
        method check($path) {
            note "$path got badchar" if $path.contains(any(badchars));
            note "$path got empty filename" if $path.split('/')[*-1] eq '.html';
            note "duplicated path $path" if %!seen-paths{$path}:exists;
            %!seen-paths{$path}++;
        }
    }
    my $path-checker = PathChecker.new;
    &spurt.wrap(sub (|c) {
        $path-checker.check(c[0]);
        callsame
    });
}

monitor UrlLog {
    has @.URLS;
    method log($url) { @!URLS.push($url) }
}
my $url-log = UrlLog.new;
sub rewrite-url-logged(\url) {
    $url-log.log: my \r = rewrite-url url;
    r
}

use experimental :cached;

my $type-graph;
my %routines-by-type;
my %*POD2HTML-CALLBACKS;
my %p5to6-functions;

# TODO: Generate menulist automatically
my @menu =
    ('language',''          ) => (),
    ('type', 'Types'        ) => <basic composite domain-specific exceptions>,
    ('routine', 'Routines'  ) => <sub method term operator>,
    ('programs', ''         ) => (),
    ('examples', 'Examples' ) => (),
    ('webchat', 'Chat with us') => (),
;

my $head = slurp 'template/head.html';

sub header-html($current-selection, $pod-path) is cached {
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
            q[</div>];
    }

    my $edit-url = "";
    if defined $pod-path {
      $edit-url = qq[
      <div align="right">
        <button title="Edit this page"  class="pencil" onclick="location='https://github.com/perl6/doc/edit/master/doc/$pod-path'">
        {svg-for-file("html/images/pencil.svg")}
        </button>
      </div>]
    }

    $header.subst('MENU', $menu-items ~ $sub-menu-items)
           .subst('EDITURL', $edit-url)
           .subst: 'CONTENT_CLASS',
                'content_' ~ ($pod-path
                    ??  $pod-path.subst(/\.pod6$/, '').subst(/\W/, '_', :g)
                    !! 'fragment');
}

sub p2h($pod, $selection = 'nothing selected', :$pod-path = Nil) {
    pod2html $pod,
        :url(&rewrite-url-logged),
        :$head,
        :header(header-html($selection, $pod-path)),
        :footer(footer-html($pod-path)),
        :default-title("Perl 6 Documentation"),
        :css-url(''), # disable Pod::To::HTML's default CSS
    ;
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
                @todo.append: $f.path;
            }
        }
    }
}

# --sparse=5: only process 1/5th of the files
# mostly useful for performance optimizations, profiling etc.
#
# --parallel=10: perform some parts in parallel (with width/degree of 10)
# much faster, but with the current state of async/concurrency
# in Rakudo you risk segfaults, weird errors, etc.
my $proc;
my $proc-supply;
my $coffee-exe = './highlights/node_modules/coffee-script/bin/coffee'.IO.e??'./highlights/node_modules/coffee-script/bin/coffee'!!'./highlights/node_modules/coffeescript/bin/coffee';
    
sub MAIN(
    Bool :$typegraph = False,
    Int  :$sparse,
    Bool :$disambiguation = True,
    Bool :$search-file = True,
    Bool :$no-highlight = False,
    Int  :$parallel = 1,
) {
    if !$no-highlight {
        if ! $coffee-exe.IO.f {
            say "Could not find $coffee-exe, did you run `make init-highlights`?";
            exit 1;
        }
        $proc = Proc::Async.new($coffee-exe, './highlights/highlight-filename-from-stdin.coffee', :r, :w);
        $proc-supply = $proc.stdout.lines;
    }
    say 'Creating html/subdirectories ...';

    for <programs type language routine images syntax> {
        mkdir "html/$_" unless "html/$_".IO ~~ :e;
    }

    my $*DR = Perl6::Documentable::Registry.new;

    say 'Reading type graph ...';
    $type-graph = Perl6::TypeGraph.new-from-file('type-graph.txt');
    my %h = $type-graph.sorted.kv.flat.reverse;
    write-type-graph-images(:force($typegraph), :$parallel);

    process-pod-dir 'Programs', :$sparse, :$parallel;
    process-pod-dir 'Language', :$sparse, :$parallel;
    process-pod-dir 'Type', :sorted-by{ %h{.key} // -1 }, :$sparse, :$parallel;

    highlight-code-blocks unless $no-highlight;

    say 'Composing doc registry ...';
    $*DR.compose;

    for $*DR.lookup("programs", :by<kind>).list -> $doc {
        say "Writing programs document for {$doc.name} ...";
        my $pod-path = pod-path-from-url($doc.url);
        spurt "html{$doc.url}.html",
            p2h($doc.pod, 'programs', pod-path => $pod-path);
    }
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

    spurt('links.txt', $url-log.URLS.sort.unique.join("\n"));
}

sub process-pod-dir($dir, :&sorted-by = &[cmp], :$sparse, :$parallel) {
    say "Reading doc/$dir ...";

    my @pod-sources =
        recursive-dir("doc/$dir/")
        .grep({.path ~~ / '.pod6' $/})
        .map({
            .path.subst("doc/$dir/", '')
                 .subst(rx{\.pod6$},  '')
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
        FIRST my @pod-files;

        push @pod-files, start {
            printf "% 4d/%d: % -40s => %s\n", $num+1, $total, $file.path, "$kind/$filename";
            my $pod = extract-pod($file.path);
            process-pod-source :$kind, :$pod, :$filename, :pod-is-complete;
        }

        if $num %% $parallel {
            await Promise.allof: @pod-files;
            @pod-files = ();
        }

        LAST await Promise.allof: @pod-files;
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

    # Special handling for 5to6-perlfunc
    if $filename eq '5to6-perlfunc' {
      find-p5to6-functions(:$pod, :$origin, :url("/$kind/$filename"));
    }
}

multi write-type-source($doc) {
    sub href_escape($ref) {
        # only valid for things preceded by a protocol, slash, or hash
        return uri_escape($ref).subst('%3A%3A', '::', :g);
    }
    my $pod     = $doc.pod;
    my $podname = $doc.name;
    my $type    = $type-graph.types{$podname};
    my $what    = 'type';

    say "Writing $what document for $podname ...";

    if !$doc.pod-is-complete {
        $pod = pod-with-title("$doc.subkinds() $podname", $pod[1..*]);
    }

    if $type {
        $pod.contents.append:
          pod-heading("Type Graph"),
          Pod::Raw.new: :target<html>, contents => q:to/CONTENTS_END/;
              <figure>
                <figcaption>Type relations for
                  <code>\qq[$podname]</code></figcaption>
                \qq[&svg-for-file("html/images/type-graph-$podname.svg")]
                <p class="fallback">
                  Stand-alone image:
                  <a rel="alternate"
                    href="/images/type-graph-\qq[uri_escape($podname)].svg"
                    type="image/svg+xml">vector</a>
                </p>
              </figure>
              CONTENTS_END

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
                    pod-link($role.name, "/type/{href_escape ~$role}"),
                    ", which provides the following methods:",
                ),
                %routines-by-type{$role}.list,
            ;
        }
        for $type.mro.skip -> $class {
            next unless %routines-by-type{$class};
            $pod.contents.append:
                pod-heading("Routines supplied by class $class"),
                pod-block(
                    "$podname inherits from class ",
                    pod-link($class.name, "/type/{href_escape ~$class}"),
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
                        pod-link($class.name, "/type/{href_escape ~$class}"),
                        ", which does role ",
                        pod-link($role.name, "/type/{href_escape ~$role}"),
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

    my @parts = $doc.url.split('/', :v);
    @parts[*-1] = replace-badchars-with-goodnames @parts[*-1];
    my $html-filename = "html" ~ @parts.join('/') ~ ".html";
    my $pod-path = pod-path-from-url($doc.url);
    spurt $html-filename, p2h($pod, $what, pod-path => $pod-path);
}

sub find-references(:$pod!, :$url, :$origin) {
    if $pod ~~ Pod::FormattingCode && $pod.type eq 'X' {
        multi sub recurse-until-str(Str:D $s){ $s }
        multi sub recurse-until-str(Pod::Block $n){ $n.contents>>.&recurse-until-str().join }

        my $index-name-attr is default(Failure.new('missing index link'));
        # this comes from Pod::To::HTML and needs to be moved into a method in said module
        # TODO use method from Pod::To::HTML
        my $index-text = recurse-until-str($pod).join;
        my @indices = $pod.meta;
        $index-name-attr = qq[index-entry{@indices ?? '-' !! ''}{@indices.join('-')}{$index-text ?? '-' !! ''}$index-text].subst('_', '__', :g).subst(' ', '_', :g).subst('%', '%25', :g).subst('#', '%23', :g);

       register-reference(:$pod, :$origin, url => $url ~ '#' ~ $index-name-attr);
}
    elsif $pod.?contents {
        for $pod.contents -> $sub-pod {
            find-references(:pod($sub-pod), :$url, :$origin) if $sub-pod ~~ Pod::Block;
        }
    }
}

sub find-p5to6-functions(:$pod!, :$url, :$origin) {
  if $pod ~~ Pod::Heading && $pod.level == 2  {
      # Add =head2 function names to hash
      my $func-name = ~$pod.contents[0].contents;
      %p5to6-functions{$func-name} = 1;
  }
  elsif $pod.?contents {
      for $pod.contents -> $sub-pod {
          find-p5to6-functions(:pod($sub-pod), :$url, :$origin) if $sub-pod ~~ Pod::Block;
      }
  }
}

sub register-reference(:$pod!, :$origin, :$url) {
    if $pod.meta {
        for @( $pod.meta ) -> $meta {
            my $name;
            if $meta.elems > 1 {
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
            );
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
        );
    }
}

#| A one-pass-parser for pod headers that define something documentable.
sub find-definitions(:$pod, :$origin, :$min-level = -1, :$url) {
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
            when :(Pod::FormattingCode $) {
                my $fc := .[0];
                proceed unless $fc.type eq "X";
                @definitions = $fc.meta[0].flat;
                # set default name if none provide so X<if|control> gets name 'if'
                @definitions[1] = $fc.contents[0] if @definitions == 1;
                $unambiguous = True;
            }
            # XXX: Remove when extra "" have been purged
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
                # trait Infix Foo
                @definitions = .split(/\s+/, 2);
            }
            when :("The ", Pod::FormattingCode $, Str $ where /^\s (\w+)$/) {
                # The C<Foo> infix
                @definitions = .[2].words[0], .[1].contents[0];
            }
            when :(Str $ where /^(\w+) \s$/, Pod::FormattingCode $) {
                # infix C<Foo>
                @definitions = .[0].words[0], .[1].contents[0];
            }
            # XXX: Remove when extra "" have been purged
            when :(Str $ where /^(\w+) \s$/, Pod::FormattingCode $, "") {
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
                    ;
                }
                when 'sub'|'method'|'term'|'routine'|'trait' {
                    %attr = :kind<routine>,
                            :categories($subkinds),
                    ;
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
                            :categories($type-graph.types{$name}.?categories // ''),
                            :$summary,
                    ;
                }
                when 'variable'|'sigil'|'twigil'|'declarator'|'quote' {
                    # TODO: More types of syntactic features
                    %attr = :kind<syntax>,
                            :categories($subkinds),
                    ;
                }
                when $unambiguous {
                    # Index anything from an X<>
                    %attr = :kind<syntax>,
                            :categories($subkinds),
                    ;
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
                :contents[pod-link "($origin.name()) $subkinds $name",
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

                note "The subkinds of routine $created.name() in $origin.name()"
                        ~ " cannot be determined. Are you sure that routine is"
                        ~ " actually defined in $origin.name()'s file?"
                    unless @subkinds;

                $created.subkinds   = @subkinds;
                $created.categories = @subkinds;
            }
            if %attr<kind> eq 'routine' {
              %routines-by-type{$origin.name}.append: $chunk;
            }
        }
        $i = $new-i + 1;
    }
    return $i;
}

sub write-type-graph-images(:$force, :$parallel) {
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
        FIRST my @type-graph-images;

        my $viz = Perl6::TypeGraph::Viz.new-for-type($type);
        @type-graph-images.push: $viz.to-file("html/images/type-graph-{$type}.svg", format => 'svg');
        if @type-graph-images %% $parallel {
            await Promise.allof: @type-graph-images;
            @type-graph-images = ();
        }

        print '.';

        LAST await Promise.allof: @type-graph-images;
    }
    say '';

    say 'Writing specialized visualizations to html/images/ ...';
    my %by-group = $type-graph.sorted.classify(&viz-group);
    %by-group<Exception>.append: $type-graph.types< Exception Any Mu >;
    %by-group<Metamodel>.append: $type-graph.types< Any Mu >;

    for %by-group.kv -> $group, @types {
        FIRST my @specialized-visualizations;

        my $viz = Perl6::TypeGraph::Viz.new(:types(@types),
                                            :dot-hints(viz-hints($group)),
                                            :rank-dir('LR'));
        @specialized-visualizations.push: $viz.to-file("html/images/type-graph-{$group}.svg", format => 'svg');
        if @specialized-visualizations %% $parallel {
            await Promise.allof: @specialized-visualizations;
            @specialized-visualizations = ();
        }

        LAST await Promise.allof: @specialized-visualizations;
    }
}

sub viz-group($type) {
    return 'Metamodel' if $type.name ~~ /^ 'Perl6::Metamodel' /;
    return 'Exception' if $type.name ~~ /^ 'X::' /;
    return 'Any';
}

sub viz-hints($group) {
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

sub write-search-file() {
    say 'Writing html/js/search.js ...';
    my $template = slurp("template/search_template.js");
    sub escape(Str $s) {
        $s.trans([</ \\ ">] => [<\\/ \\\\ \\">]);
    }
    my @items = $*DR.get-kinds.map(-> $kind {
        $*DR.lookup($kind, :by<kind>).categorize({escape .name})\
            .pairs.sort({.key}).map: -> (:key($name), :value(@docs)) {
                qq[[\{ category: "{
                    ( @docs > 1 ?? $kind !! @docs.[0].subkinds[0] ).wordcase
                }", value: "$name",
                    url: " {rewrite-url-logged(@docs.[0].url).subst(｢\｣, ｢%5c｣, :g).subst('"', '\"', :g).subst(｢?｣, ｢%3F｣, :g) }" \}
                  ]] # " and ?
            }
    }).flat;

    # Add p5to6 functions to JavaScript search index
    @items.append: %p5to6-functions.keys.map( {
      my $url = "/language/5to6-perlfunc#" ~ $_.subst(' ', '_', :g);
      sprintf(
        q[[{ category: "5to6-perlfunc", value: "%s", url: "%s" }]],
        $_, $url
      );
    });
    spurt("html/js/search.js", $template.subst("ITEMS", @items.join(",\n") ).subst("WARNING", "DO NOT EDIT generated by $?FILE:$?LINE"));
}

sub write-disambiguation-files() {
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
                        );
                    }
                    else {
                        pod-item( pod-link(.human-kind, .url) );
                    }
                });
        }
        my $html = p2h($pod, 'routine');
        spurt "html/{replace-badchars-with-goodnames $name}.html", $html;
    }
    say '';
}

sub write-index-files() {
    say 'Writing html/index.html and html/404.html...';
    spurt 'html/index.html',
        p2h(extract-pod('doc/HomePage.pod6'),
            pod-path => 'HomePage.pod6');

    spurt 'html/404.html',
        p2h(extract-pod('doc/404.pod6'),
            pod-path => '404.pod6');

    # sort programs index by file name to allow author control of order
    say 'Writing html/programs.html ...';
    spurt 'html/programs.html', p2h(pod-with-title(
        'Perl 6 Programs Documentation',
        pod-table($*DR.lookup('programs', :by<kind>).map({[
            pod-link(.name, .url),
            .summary
        ]}))
    ), 'programs');

    say 'Writing html/language.html ...';
    spurt 'html/language.html', p2h(pod-with-title(
        'Perl 6 Language Documentation',
        pod-block("Tutorials, general reference, migration guides and meta pages for the Perl 6 language, in alphabetical order. Scroll down or search 'tutorial' or 'from' to see all of them."),
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
        pod-table(
            :headers[<Name  Declarator  Source>],
            [
                $*DR.lookup($kind, :by<kind>)\
                .categorize(*.name).sort(*.key)>>.value
                .map({[
                    pod-link(.[0].name, .[0].url),
                    .map({.subkinds // Nil}).flat.unique.join(', '),
                    .&summary
                ]}).cache.Slip
            ].flat
        )
    ), $kind);
}

# XXX: Only handles normal routines, not types nor operators
sub write-sub-index(:$kind, :$category, :&summary = {Nil}) {
    say "Writing html/$kind-$category.html ...";
    my $this-category = $category.tc eq "Exceptions" ?? "Exception" !! $category.tc;
    spurt "html/$kind-$category.html", p2h(pod-with-title(
        "Perl 6 {$this-category} {$kind.tc}s",
        pod-table($*DR.lookup($kind, :by<kind>)\
            .grep({$category ⊆ .categories})\ # XXX
            .categorize(*.name).sort(*.key)>>.value
            .map({[
                .map({slip .subkinds // Nil}).unique.join(', '),
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
            my @subkinds = @docs.map({slip .subkinds}).unique;
            my $subkind = @subkinds == 1 ?? @subkinds[0] !! $kind;
            my $pod = pod-with-title(
                "$subkind $name",
                pod-block("Documentation for $subkind ", pod-code($name), " assembled from the following types:"),
                @docs.map({
                    pod-heading("{.origin.human-kind} {.origin.name}"),
                    pod-block("From ",
                        pod-link(.origin.name,
                                 .origin.url ~ '#' ~ (.subkinds~'_' if .subkinds ~~ /fix/) ~
                                  (
                                      if .subkinds ~~ /fix/ { '' }
                                      # It looks really weird, but in reality, it checks the pod content,
                                      # then extracts a link(e.g. '(Type) routine foo'), then this string
                                      # splits by space character and we take a correct category name.
                                      # It works with sub/method/term/routine/*fix types, so all our links
                                      # here are correct.
                                      else { .pod[0].contents[0].contents.Str.split(' ')[1] ~ '_'; }
                                  ) ~ .name.subst(' ', '_')),
                    ),
                    .pod.list,
                })
            );
            print '.';
            spurt "html/$kind/{replace-badchars-with-goodnames $name}.html", p2h($pod, $kind);
        }
    say '';
}

sub get-temp-filename {
    state %seen-temps;
    my $temp = join '-', %*ENV<USER> // 'u', (^1_000_000).pick, 'pod_to_pyg.pod';
    while %seen-temps{$temp} {
        $temp = join '-', %*ENV<USER> // 'u', (^1_000_000).pick, 'pod_to_pyg.pod';
    }
    %seen-temps{$temp}++;
    $temp;
}
sub highlight-code-blocks {
    $proc.start andthen say "Starting highlights worker thread" unless $proc.started;
    %*POD2HTML-CALLBACKS = code => sub (:$node, :&default) {
        for @($node.contents) -> $c {
            if $c !~~ Str {
                # some nested formatting code => we can't highlight this
                return default($node);
            }
        }
        my $basename = get-temp-filename();
        my $tmp_fname = $*TMPDIR ~ ($*TMPDIR.ends-with('/') ?? '' !! '/') ~ $basename;
        spurt $tmp_fname, $node.contents.join;
        LEAVE try unlink $tmp_fname;
        my $html;
        my $promise = Promise.new;
        my $tap = $proc-supply.tap( -> $json {
            my $parsed-json = from-json($json);
            if $parsed-json<file> eq $tmp_fname {
                $promise.keep($parsed-json<html>);
                $tap.close();
            }
        } );
        $proc.say($tmp_fname);
        await $promise;
        $promise.result;
    }
}

#| Determine path to source POD from the POD object's url attribute
sub pod-path-from-url($url) {
    my $pod-path = $url.subst('::', '/', :g) ~ '.pod6';
    $pod-path.subst-mutate(/^\//, '');  # trim leading slash from path
    $pod-path = $pod-path.tc;

    return $pod-path;
}

sub warn-user (Str $warn-text) {
    my $border = '=' x $warn-text.chars;
    note "\n$border\n$warn-text\n$border\n";
}
# vim: expandtab shiftwidth=4 ft=perl6
