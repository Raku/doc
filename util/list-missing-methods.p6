#! /usr/bin/env raku
use v6;
use Telemetry;
use Test;

class Summary     {...}
class Report      {...}
grammar MethodDoc {...}

my $util_dir := $*PROGRAM.resolve.parent;
constant $report_opts   = (<s skip>, <p pass>, <f fail>, <e err>, <o over>, <u under>, <a all>, <n none>);
constant $summary_opts  = (<t totals>, <i introspect>,            <o over>, <u under>, <a all>, <n none>);

#| Allowable values for --report
subset ReportCsv  of Str:D where *.split(',')».trim ⊆ ($report_opts.flat);
#| Allowable values for --summary
subset SummaryCsv of Str:D where *.split(',')».trim ⊆ ($summary_opts.flat);

#| Scan a pod6 file or directory of pod6 files for over- and under-documented methods
sub MAIN(
    IO(Str) $input-path = "{$util_dir.parent}/doc/Type", #= Path to the file or directory to check
    Str :exclude(:$e),                                   #= Exclude files matching Regex
    Str :exclude-dir(:$E),                               #= Exclude directories matching Regex
    Str :only(:$o),                                      #= Include ONLY files matching Regex
    Str :only-dir(:$O),                                  #= Include ONLY files within one or more directories
                                                         #= matching Regex
    ReportCsv  :report(:$r)  = 'all',                    #= Comma-separated list of documentation types to display
    SummaryCsv :summary(:$s) = 'all',                    #= Comma-separated list of summary types to display
    Bool :h(:$help),                                     #= Display this message and exit
    Str :i(:$ignore) = "$util_dir/ignored-methods.txt",  #= Path to file with methods to skip
) {
    when $help { USAGE }
    # normalize long & short options for --summary & --report
    my $reports   =  $report_opts.map(-> ($short, $l) {if  $short | $l ∈  $r.split(',')».trim { $l }}).cache;
    my $summaries = $summary_opts.map(-> ($short, $l) {if  $short | $l ∈  $s.split(',')».trim { $l }}).cache;
    my $reports-to-print   := any('all' ∈ $reports   ??  $report_opts[^(*-1)]»[1] !! |$reports);
    my $summaries-to-print := any('all' ∈ $summaries ?? $summary_opts[^(*-1)]»[1] !! |$summaries);

    # avoid perf penalty of re-constructing Regex
    my %filters = exclude => do with $e { /<$e>/ }, exclude-dir => do with $E { /<$E>/ },
                  only    => do with $o { /<$o>/ }, only-dir    => do with $O { /<$O>/ };
    my $summary := Summary.new;

    for $input-path.&process-pod6(:%filters, ignored-types => EVALFILE($ignore)).map(
        -> (:%file, :%methods (:%uncheckable, :%over-documented, :%under-documented, :%introspection, *%)) {
            when %file<no-type-found> {
                if $reports-to-print ~~ 'err'  { Report::fmt-bad-file(%file<path>)}}
            when %file<uncheckable> {
                $summary.count-uncheckable-type;
                if $reports-to-print ~~ 'skip' { Report::fmt-skipped(:%file) }}
            $summary.update-totals(|%methods);
            $summary.update-over-documented(:%over-documented,   :%file);
            $summary.update-under-documented(:%under-documented, :%file);
            $summary.update-introspection(:%introspection);

            my $status := (%uncheckable.values ∪  |%under-documented.values ∪ |%over-documented.values
                           ?? '✗' !! '✔');
            (if (($reports-to-print ~~ 'pass')  && $status eq '✔')
             || (($reports-to-print ~~ 'skip')  && ?%uncheckable.values».List.flat)
             || (($reports-to-print ~~ 'under') && ?%under-documented.values».List.flat)
             || (($reports-to-print ~~ 'over')  &&  ?%over-documented.values».List.flat) {
                    "\n$status {%file<type-name>} – documented at ⟨%file<path>.IO}⟩\n"
            })

            ~ (if $reports-to-print ~~ ('skip')  { Report::fmt(:%uncheckable) })
            ~ (if $reports-to-print ~~ ('under') { Report::fmt(:%under-documented) })
            ~ (if $reports-to-print ~~ ('over')  { Report::fmt(:%over-documented) });
        }
    ) { .print };

    if $summaries-to-print !~~ 'none'       { print $summary.fmt-header };
    if $summaries-to-print ~~  'totals'     { print $summary.fmt-totals };
    if $summaries-to-print ~~  'under'      { print $summary.fmt-under-documented };
    if $summaries-to-print ~~  'over'       { print $summary.fmt-over-documented };
    if $summaries-to-print ~~  'introspect' { print $summary.fmt-introspection;}
}

#| Process a directory of Pod6 files by recursively processing each file
multi process-pod6($path where {.IO ~~ :d}, :%ignored-types,
                   :%filters (:$exclude, :$exclude-dir, :$only, :$only-dir) --> List) {
    |(lazy $path.dir ==> grep( -> $path {
                             when $path ~~ :d { all((with $exclude-dir { $path.basename !~~ $_}))}
                             all( (with $exclude     { $path.basename !~~ $_}),
                                  (with $only        { $path.basename  ~~ $_}),
                                  (with $only-dir    { $path.parent    ~~ $_}))})
                     ==> map({ |process-pod6($^next-path, :%filters, :%ignored-types )}))
}

#| Process a Pod6 file by parsing with the MethodDoc grammar and then comparing
#| the documented methods against the methods visible via introspection
multi process-pod6($path, :%ignored-types, *%  --> List ) {
    POST { with .[0]<methods> { $_ ~~ Set | Bag | Map } else { True }}

    when $path !~~ /.*'doc/Type/'(.*).pod6/ { (%(file => Map.new((no-type-found => True,  :$path))), )}
    my $type-name := (S/.*'doc/Type/'(.*).pod6/$0/).subst(:g, '/', '::') with $path;

    # if we're at a low enough level that this amount of introspection fails, skip the type
    try { ::($type-name).^methods;
          CATCH { default { return (%(file => Map.new((uncheckable => True, :$type-name, :$path))), )}} }

    my %methods := (::($type-name).^methods(:local).classify(
                          {classify-method($_, $type-name, %ignored-types{"$type-name"} // ());},
                          :into( %(<local ignored other-missing-introspection native-code
                                    from-a-role from-any from-mu from-other>.map(*=> []))),
                          :as(*.name) ));
    my ( :$local, :$from-a-role, :$from-any, :$ignored, :$from-mu,
         :$from-other, :$other-missing-introspection, *% ) := %methods.map({.key => .value.Set});
    my $native-code := Bag.new(%methods<native-code><>);
    # TODO: add support for %ignored-types<GLOBAL> ^^^^^

    my (:@in-header, :@with-signature) :=
            $path.IO.lines.map({ MethodDoc.parse($_).made }).grep(*.defined).classify(*.key, :as{.value});
    my Set $missing-header    := $local (-) Set.new(@in-header);
    my Set $missing-signature := $local (-) @with-signature (-) $missing-header;
    my %over-documented       := (@in-header (-) $local).keys.classify(
        {classify-documented($_, $type-name)},
        ## TODO: consider meta-operators here
        :into(%(<doesn't-exist non-local non-method>.map(* => []))));
    my (:$non-local, :$non-method, :$doesn't-exist) := %over-documented.kv.map(-> $k, $v { $k => $v.Set});

    List.new(Map.new(
        ( file    => Map.new((:$type-name, :$path)),
          methods => Map.new(
              ( uncheckable      => Map.new((:$other-missing-introspection, :$native-code)),
                ignored          => $ignored,
                introspection    => Map.new(
                    ( over-inclusive => Map.new((:$from-a-role, :$from-any,
                                                 :$from-mu, :$from-other)),
                      missing        => Map.new((:native-code, :$other-missing-introspection)))),
                under-documented => Map.new((:$missing-header, :$missing-signature)),
                over-documented  => Map.new((:$non-local, :$non-method, :$doesn't-exist)),
                all-good         => [(-)] $local, $other-missing-introspection, $native-code, $missing-header,
                                             $missing-signature, |%over-documented.values)))))
}

#TODO doc here
sub classify-method(Mu $method, $type-name, List $ignored-methods) {
    when $method.name ∈ $ignored-methods                  { 'ignored' };
    # Some builtins don't support the introspection we need, mostly ones that call ForeignCode
    # (which includes NQP methods).  ForeignCode methods typically have the name `<anon>`
    when $method.name eq '<anon>'                         { 'native-code' };
    CATCH {  when X::Method::NotFound {
                  when .method ~~ 'roles' | 'candidates'  { return 'other-missing-introspection' } } }

    # we treat a multi method as local if any of it's variants are in the Type's package
    my $packages = (?$method.candidates ?? $method.candidates !! $method).map(*.package).cache;
    when ?any($packages.map({ try .isa($type-name)}))     { 'local'}
    when ?any($packages.map({ try $_ ~~ ::($type-name)})) { 'local'}
    when  any($packages) ~~ any(::($type-name).^roles)    { 'from-a-role' }
    # For low level types, === won't work, so use string comparison
    when  $packages.head.^name eq 'Any'                   { 'from-any' }
    when  $packages.head.^name eq 'Mu'                    { 'from-mu' }
    default                                               { 'from-other' }
}

sub classify-documented(Mu $method, $type-name) {
    # if ^find_method finds it, it's *somewhere* in the inheritance graph, just not local
    when try {::($type-name).^find_method($method).defined} { 'non-local' }
    # If the type matches first item in the signature, then it's a sub the type can call with .&…
    when try { any(&::($method).candidates.map(-> $a {::($type-name) ~~ $a.signature.params.head.type}))} {
        'non-method'
    }
    "doesn't-exist"
},

# Formats reports for individual Types (displayed with --report)
class Report {
    our sub fmt-skipped(:%file (:$type-name, :$path, *%)) {
        "\n∅ {$type-name} – documented at  ⟨{$path.IO}⟩\n  Skipped as uncheckable\n"
    }
    our sub fmt-bad-file($path) {
        "\n! ERR could not process file at ⟨{$path.IO}⟩\n  Does it contain documentation for a Raku type?\n"
    }

    our proto fmt(|) {*}

    multi fmt(:%uncheckable) {
        ~( if %uncheckable<other-missing-introspection> {
            "{+%uncheckable<other-missing-introspection>} method without introspection:\n".&pluralize('method').indent(2)
            ~ (%uncheckable<other-missing-introspection>.keys.sort.join("\n").indent(4) ~ "\n")})
        ~( if %uncheckable<native-code> {
            "{+%uncheckable<native-code>} method implemented in native-code/NQP:\n".&pluralize('method').indent(2)
            ~ (%uncheckable<native-code>.keys.sort.join("\n").indent(4) ~ "\n")})
    }
    multi fmt(:%over-documented) {
        my (:$non-local, :$non-method, :$doesn't-exist) := %over-documented;
        ~( if $non-local {
            "{+$non-local} non-local method with documentation:\n".&pluralize('method').indent(2)
            ~ $non-local.keys.sort.join("\n").indent(4) ~ "\n"})
        ~( if $non-method {
            "{+$non-method} non-method with documentation:\n".&pluralize('non-method').indent(2)
            ~ $non-method.keys.sort.join("\n").indent(4) ~ "\n"})
        ~( if $doesn't-exist {
            "{+$doesn't-exist} non-existing method with documentation:\n".&pluralize('method').indent(2)
            ~ $doesn't-exist.keys.sort.join("\n").indent(4) ~ "\n"})
    }
    multi fmt(:%under-documented) {
        my (:%missing-header, :%missing-signature) := %under-documented;
        ~ ( if +%missing-header {
             "{+%missing-header} missing method:\n".&pluralize('method').indent(2)
             ~ %missing-header.keys.sort.join("\n").indent(4) ~ "\n" })
        ~ ( if %missing-signature {
             ("{+%missing-signature} method without signature:\n"
                 ).&pluralize('method').&pluralize('signature').indent(2)
             ~ %missing-signature.keys.sort.join("\n").indent(4) ~ "\n"})
    }

    #| Appends an 's' to the provided $noun if the closest preceding number in $phrase is ≥ 2
    sub pluralize(Str $phrase, Str $noun --> Str) {
        $phrase ~~ /(\d+) \D* $noun/;
        +$0 == 1 ?? $phrase !! $phrase.subst(/$noun/, $noun ~ 's')
    }

}

#| Collects and formats summary statistics (displayed with --summary)
class Summary {
    has Map $!totals;
    has Map $!under-documented;
    has Map $!over-documented;
    has Map $!introspection;


    # Hard-coded constants that change Summary output.  (Could be user-configurable if wanted)
    constant $missing_method_threshold    = 20;
    constant $overdocked_method_threshold = 20;
    constant $most_missing_list_length    = 5;
    constant $most_overdocked_list_length = 5;
    constant $line-length = 40;
    constant $head = '#' x $line-length;
    constant $subhead = '=' x $line-length;
    my &center = { .lines.map({' ' x ($line-length - .chars) ÷ 2 ~ $_}).join("\n")}



    submethod BUILD() {
        # Maps with scallar values gives interior mutiablity but guarentees we can't typo keys
        $!totals := Map.new(
            ( types   => Map.new((skip => $=0, pass => $=0, fail => $=0)),
              methods => Map.new((skip => $=0, pass => $=0, ignored => $=0,
                                  under => $=0, over => $=0, introspection => $=0))));
        $!under-documented := Map.new(
            ( sums                       => Map.new((missing-header => $=0, missing-signature => $=0)),
              missing-per-type           => BagHash.new(),
              times-missing-by-method    => BagHash.new()));
        $!over-documented  := Map.new(
            ( sums                       => Map.new((doesn't-exist => $=0, non-method => $=0, non-local => $=0)),
              missing-per-type           => BagHash.new(),
              times-overdocked-by-method => BagHash.new()));
        $!introspection := Map.new(
            ( over-inclusive             => Map.new((from-a-role => $=0, from-any => $=0, from-mu => $=0,
                                                     from-other => $=0, anon => $=0)),
              missing                    => Map.new((native-code => $=0, other-missing-introspection => $=0))),

        );
    }

    submethod update-introspection(:%introspection) {
        for %introspection<missing>.kv { $!introspection<missing>{$^key} += +$^value};
        for %introspection<over-inclusive>.kv { $!introspection<over-inclusive>{$^key} += +$^value};
    }

    submethod fmt-introspection() {
        my (:$missing, :$over-inclusive) := $!introspection;
        qq:to/EOF/

        {'INTROSPECTION ISSUES:'.&fmt-head.&center}

         {'Methods without needed introspection:'.&center}
         $subhead
         NativeCall methods:                 {sprintf('%4d', $missing<native-code>)}
         Other non-introspecable methods:    {sprintf('%4d', $missing<other-missing-introspection>)}
        {fmt-sum($missing.values.sum)}

         {'local methods actually from:'.&center}
         $subhead
         ...a role                           { sprintf('%4d', $over-inclusive<from-a-role>)}
         ...Any                              { sprintf('%4d', $over-inclusive<from-any>)}
         ...Mu                               { sprintf('%4d', $over-inclusive<from-mu>)}
         ...some other type                  { sprintf('%4d', $over-inclusive<from-other>)}
        {fmt-sum($over-inclusive.values.sum)}
        EOF
    }

    submethod count-uncheckable-type() { $!totals<types><skip>++ }

    submethod fmt-header() { fmt-head('SUMMARY').&center ~ "\n" }

    submethod update-totals(:$ignored, :$all-good, :%under-documented, :%over-documented,
                            :%introspection, :%uncheckable) {
        %uncheckable.values ∪ |%under-documented.values ∪ |%over-documented.values
                ?? $!totals<types><fail>++
                !! $!totals<types><pass>++;
        given $!totals<methods> {
            .<skip>            += +%uncheckable.values».List.flat;
            .<ignored>         += +$ignored;
            .<pass>            += +$all-good;
            .<under>           += +%under-documented.values».List.flat;
            .<over>            += +%over-documented.values».List.flat;
            .<introspection> += +%introspection.values».List.flat;
        }
    }

    submethod fmt-totals() {
        my (:%types, :%methods) := $!totals;
        do { my $checked  = %types<pass> + %types<fail>;
             my $detected = %types<skip> + $checked;
             qq:to/EOF/

              { 'Total types processed:'.&center }
              $subhead
              documented types detected:          {sprintf('%4d', $detected)}
              types checked:                      {$checked.&fmt-with-percent-of(:$detected)}
              types skipped:                      {%types<skip>.&fmt-with-percent-of(:$detected)}
              problems found:                     {%types<fail>.&fmt-with-percent-of(:$checked)}
              no problems found:                  {%types<pass>.&fmt-with-percent-of(:$checked)}
             EOF
           } ~ do {
            my $checked  = %methods<pass> + %methods<over> + %methods<under>;
            my $detected = %methods<skip> + $checked;
            qq:to/EOF/

             { 'Total methods processed:'.&center }
             $subhead
             documented methods detected:        { sprintf('%4d', $detected)}
             unprocessable methods skipped:      { %methods<skip>.&fmt-with-percent-of(:$detected)}
             explicitly ignored methods:         { %methods<ignored>.&fmt-with-percent-of(:$detected)}
             methods checked:                    { $checked.&fmt-with-percent-of(:$detected)}
             over-documented methods:            { %methods<over>.&fmt-with-percent-of(:$checked)}
             under-documented methods:           { %methods<under>.&fmt-with-percent-of(:$checked)}
             introspection issue detected:       { sprintf('%4d', %methods<introspection>)}
             problem-free methods:               { %methods<pass>.&fmt-with-percent-of(:$checked)}
            EOF
        }
    }

    submethod update-under-documented(:%under-documented, :%file (:$type-name, *%)) {
        $!under-documented<missing-per-type>{$type-name} += +%under-documented<missing-header>;
        $!under-documented<sums><missing-signature>      += +%under-documented<missing-signature>;
        for %under-documented<missing-header>.keys -> $method {
            $!under-documented<sums><missing-header>++;
            $!under-documented<times-missing-by-method>.add($method)};
    }

    submethod fmt-under-documented() {
        my (:%sums, :%times-missing-by-method, :%missing-per-type) := $!under-documented;
        my $total = %sums<missing-header> + %sums<missing-signature>;
        my $top-missing = %times-missing-by-method
                              .grep(*.value ≥ $missing_method_threshold)
                              .sort({.value, .key})
                              .cache;
        my $top-types = %missing-per-type.sort({.value, .key}).tail($most_missing_list_length).cache;

        qq:to/EOF/

        { 'UNDER-DOCUMENTED:'.&fmt-head.&center }

         { '(Potentially) under-documented methods:'.&center }
         { $subhead }
         missing methods:                    { %sums<missing-header>.&fmt-with-percent-of(:$total)}
         methods with no signature:          { %sums<missing-signature>.&fmt-with-percent-of(:$total)}
        {fmt-sum($total)}
        EOF
        ~ (if $top-missing {
                  ~ " \n{'Methods missing from 20+ types:'.&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-methods($top-missing) ~ "\n"
              })
        ~ (if $top-types.elems {
                  ~ " \n{'Types with most missing methods:'.&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-methods($top-types)}) ~ "\n"
    }

    submethod update-over-documented(:%over-documented, :%file (:$type-name, *%)) {
        $!over-documented<sums>{.key} += .value.elems for %over-documented.pairs;
        $!over-documented<missing-per-type>{$type-name} += +%over-documented<doesn't-exist>;
        for %over-documented<doesn't-exist>.keys -> $method {
            $!over-documented<times-overdocked-by-method>.add($method)};
    }

    submethod fmt-over-documented() {
        my (:%sums, :%missing-per-type, :%times-overdocked-by-method) := $!over-documented;

        my $total = %sums<non-local> + %sums<non-method> + %sums<doesn't-exist>;
        my $top-types = %missing-per-type.sort({.value, .key}).tail($most_overdocked_list_length).cache;
        my $top-overdocked = %times-overdocked-by-method.grep(*.value ≥ $overdocked_method_threshold).cache;
        qq:to/EOF/

        { 'OVER-DOCUMENTED:'.&fmt-head.&center }

         { 'Total over-documented methods:'.&center }
         $subhead
         non-local methods:                  {%sums<non-local>.&fmt-with-percent-of(:$total)}
         non-method routines:                {%sums<non-method>.&fmt-with-percent-of(:$total)}
         non-existent methods:               {%sums<doesn't-exist>.&fmt-with-percent-of(:$total)}
        {fmt-sum($total)}
        EOF
        ~ (if $top-overdocked {
                  ~ "\n {'Overdocumented methods in 20+ types:'.&center}\n"
                  ~ " {$subhead}\n"
                  ~ fmt-top-methods($top-overdocked) ~ "\n"
              })
        ~ (if $top-types.elems ≥ 3 {
                  ~ "\n {'Types with most over-documented methods:'.&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-methods($top-types) ~ "\n" })
    }


    sub fmt-top-methods($top-methods) {
                  ~ $top-methods.sort(*.value).map({ sprintf(" %-*s%3d",
                                                             ($line-length - 3), .key,
                                                             .value)}).join("\n") ~ "\n"
                  ~ fmt-sum($top-methods.map(*.value).sum ~ "\n")
    }

    #| Returns the length of the longest key in a list of pairs
    sub max-len(List $pairs --> Int) { $pairs.max(*.key.chars).key.chars }

    #| Format a number as a percent of a pair's value, and label it with the key's name
    sub fmt-with-percent-of($num, *%names where *.elems == 1) {
        my $name = S:g/'-'/ / with %names.head.key;
        sprintf("%4d (%4.1f%% of $name)", $num, 100 × $num/%names.head.value)
    }

    sub fmt-head($txt) { my $mid = $txt.lines.map({"#    {$_}    #"}).join("\n");
                         given '#' x $mid.lines.map(&chars).sum {($_, $mid, $_).join("\n")}
    }

    sub fmt-sum($num) {
        given 'TOTAL', 5 -> ($txt, $num-len ){
            ('-' x $line-length  ~ "\n").indent(1)
            ~ ' ' x $line-length + 1 - $txt.chars - $num-len ~ $txt ~ sprintf('%*d', $num-len, $num)}
    }
}

#| Parses a Pod6 document and returns all methods mentioned in a header or given a signature
grammar MethodDoc {
    token TOP { <doc-line> { make $<doc-line>.made }}

    proto rule doc-line          {*}
    rule doc-line:sym<signature> { <.ws>['multi' ]?<method-decl>'('.+  { make (with-signature => ~$<method-decl>)}}
    rule doc-line:sym<in-header> {      '=head'\d? <method-decl>       { make (in-header      => ~$<method-decl>)}}
    token method-decl            { ['method' | 'routine'] <.ws> <(<[-'\w]>+)>}
}


#| Provide dynamic usage info, including default values assigned in MAIN
sub USAGE() {
    my &fmt-param = { $^a ~ (' ' x (20 - $^a.chars) ~ $^b.WHY ~ (with $^b.default { " [default: {.()}]"})) }
    # TODO: add info about meaning of output for over- and under-documented methods.
    # TODO: Update for new functionality

    print S:g/'/home/'$(%*ENV<USER>)/~/ with do given &MAIN.signature.params {
      "Usage: ./{$*PROGRAM.relative} [FLAGS]... [OPTION]... [ARG]\n"
      ~ "{&MAIN.WHY}\n\n"
      ~ (with .grep(!*.named) {
          "ARGS:\n"
          ~ .map({ fmt-param(.name.substr(1).uc, $_) }).join("\n").indent(2) ~ "\n\n"})
      ~ (with .grep({.named && .type ~~ Bool}) {
          "FLAGS:\n"
          ~ .map({
              fmt-param(.named_names.sort(*.chars).map({'-' x ++$ ~ $_}).join(', '), $_);
             }).join("\n  ").indent(2) ~ "\n\n"})
      ~ (with .grep({.named && .type !~~ Bool}) {
                "OPTIONS:\n"
                ~ .map({
              fmt-param(.named_names.sort(*.chars).map({'-' x ++$ ~ $_}).join(', '), $_);
          }).join("\n").indent(2) ~ "\n\n"})
      ~ qq:to/EOF/
      By default, this script displays a large amount of information for each type it
      analyzes: all methods potentially missing documentation, all methods that are
      potentially over-documented, and all types that were skipped (typically because
      they are low-level types that lack the required introspective abilities). This
      corresponds to `--display=all`.  You can pass a comma-separated list consisting of
      any of `over`, `under`, or `skip` to view a subset of information for each type.

      Additionally, this script also displays summary statistics based on all types it
      analyzed.  To omit this summary info, use `--summary=no`; to display *only* this
      summary info (that is, to hide all type-level info) use `--summary=only`
      EOF
    }
}

#| Provide error messages that inform the user what unsupported parameter they passed
sub GENERATE-USAGE(&main, |capture) {
    my $last-invalid; my $cap = capture;
    while $cap !~~ &main.signature {
        $last-invalid = $cap.pairs.tail;
        $cap = $cap.hash ?? \(|$cap.list, |$cap.hash.head(*-1).hash )
                         !! \(|$cap.list.head(*-1).list);
    }
    (given $last-invalid {
         when .key ~~ Int    { "Unrecongnized positional argument '{$last-invalid.value}'" }
         when .value ~~ Bool { "Unrecongnized flag '{$last-invalid.key}'" }
         default             { "Invalid option '{$last-invalid.key}={$last-invalid.value}'" }
    })
    ~ "\nUse ./{$*PROGRAM.relative} --help for usage info"
}
