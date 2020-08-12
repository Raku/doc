#! /usr/bin/env raku
use v6;
use Telemetry;
use Test;

class Summary     {...}
class Report      {...}
grammar MethodDoc {...}

# TODO consider adding priority based on ^can or ^roles

# Hard-coded constants that change Summary output.  (Could be user-configurable if wanted)
constant $missing_method_threshold    = 20;
constant $overdocked_method_threshold = 20;
constant $most_missing_list_length    = 5;
constant $most_overdocked_list_length = 5;
my $util_dir := $*PROGRAM.resolve.parent;

#| Allowable values for --report
subset ReportCsv  of Str:D where *.split(',')».trim ⊆ <skip pass fail err over under all none>;
#| Allowable values for --summary
subset SummaryCsv of Str:D where *.split(',')».trim ⊆ <totals             over under all none>;

#| Scan a pod6 file or directory of pod6 files for over- and under-documented methods
sub MAIN(
    IO(Str) $input-path = "{$util_dir.parent}/doc/Type", #= Path to the file or directory to check
    # TODO: add --exclude-dir and --only-dir and change --exclude and --only to just be files
    Str :exclude(:$e),                                   #= Exclude files or directories matching Regex
    Str :only(:$o),                                      #= Include ONLY files or directories matching Regex
    ReportCsv  :report(:$r)  = 'all',                    #= Comma-separated list of documentation types to display
    SummaryCsv :summary(:$s) = 'all',                    #= Comma-separated list of summary types to display
    Bool :h(:$help),                                     #= Display this message and exit
    Str :i(:$ignore) = "$util_dir/ignored-methods.txt",  #= Path to file with methods to skip
) {
    when $help { USAGE }
    my $reports-to-print   := any(|(S/'all'/skip,pass,fail,err,over,under/ with $r).split(',')».trim);
    my $summaries-to-print := any(|(S/'all'/totals,over,under/             with $s).split(',')».trim);
    my $exclude := do with $e {/<$e>/};
    my $only    := do with $o {/<$o>/}; # avoid perf penalty of re-constructing Regex
    my $summary := Summary.new;

    for $input-path.&process-pod6($exclude, $only, ignored-types => EVALFILE($ignore)).map(
        -> (:%file, :%methods (:%uncheckable, :%over-documented, :%under-documented, :%false-positives, *%)) {
            when %file<no-type-found> {
                if $reports-to-print ~~ 'err'  { Report::fmt-bad-file(%file<path>)}}
            when %file<uncheckable> {
                $summary.count-uncheckable-type;
                if $reports-to-print ~~ 'skip' { Report::fmt-skipped(:%file) }}
            $summary.update-totals(|%methods);
            $summary.update-over-documented(:%over-documented,   :%file);
            $summary.update-under-documented(:%under-documented, :%file);
            $summary.update-false-postives(:%false-positives);

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

    if $summaries-to-print !~~ 'none'   { print $summary.fmt-header };
    if $summaries-to-print ~~  'totals' { print $summary.fmt-totals };
    if $summaries-to-print ~~  'under'  { print $summary.fmt-under-documented };
    if $summaries-to-print ~~  'over'   { print $summary.fmt-over-documented };
    print $summary.fmt-false-positives;
}

#| Process a directory of Pod6 files by recursively processing each file
multi process-pod6($path where {.IO ~~ :d}, $exclude, $only, :%ignored-types --> List) {
    |(lazy $path.dir ==> grep( -> $file { all( (with $exclude { $file.basename !~~ $exclude }),
                                               (with $only    { $file.basename  ~~ $only }),
                                               True )})
                     ==> map({ |process-pod6($^next-path, $exclude, $only, :%ignored-types )}))
}
sub set_bag($el) { when $el.isa('Set') || $el.isa('Bag') { True }
                   when $el.isa('Map')                   { $el.values».&set_bag }
                   default                               { False }
                            }
#| Process a Pod6 file by parsing with the MethodDoc grammar and then comparing
#| the documented methods against the methods visible via introspection
multi process-pod6($path, $?, $?, :%ignored-types  --> List ) {
    # Every item in .<methods> is a Set|Bag or a Map containing Set|Bag
    POST { with .[0]<methods> { ?all(.values».&set_bag) } else { True }}

    when $path !~~ /.*'doc/Type/'(.*).pod6/ { (%(file => Map.new((no-type-found => True,  :$path))), )}
    my $type-name := (S/.*'doc/Type/'(.*).pod6/$0/).subst(:g, '/', '::') with $path;

    # if we're at a low enough level that this amount of introspection fails, skip the type
    try { ::($type-name).^methods;
          CATCH { default { return (%(file => Map.new((uncheckable => True, :$type-name, :$path))), )}} }

    my %methods := (::($type-name).^methods(:local).classify(
                          {classify-method($_, $type-name, %ignored-types{"$type-name"} // ());},
                          :into( %(<local ignored lacks-introspection native-code
                                    from-a-role from-any from-mu from-other>.map(*=> []))),
                          :as(*.name) ));
    my ( :$local, :$from-a-role, :$from-any, :$ignored, :$from-mu,
         :$from-other, :$lacks-introspection, *% ) := %methods.map({.key => .value.Set});
    my $native-code := Bag.new(%methods<native-code><>);
    # TODO: add support for %ignored-types<GLOBAL> ^^^^^

    my (:@in-header, :@with-signature) :=
            $path.IO.lines.map({ MethodDoc.parse($_).made }).grep(*.defined).classify(*.key, :as{.value});
    my Set $missing-header    := $local (-) Set.new(@in-header);
    my Set $missing-signature := $local (-) @with-signature (-) $missing-header;
    my %over-documented       := (@in-header (-) $local).keys.classify(
        {classify-documented($_, $type-name)},
        :into(%(<doesn't-exist non-local non-method>.map(* => []))));
    my (:$non-local, :$non-method, :$doesn't-exist) := %over-documented.kv.map(-> $k, $v { $k => $v.Set});

    List.new(Map.new(
        ( file    => Map.new((:$type-name, :$path)),
          methods => Map.new(
              ( uncheckable         => Map.new((:$lacks-introspection, :$native-code)),
                ignored             => $ignored,
                false-positives     => Map.new((:$from-a-role, :$from-any, :$from-mu, :$from-other)),
                under-documented    => Map.new((:$missing-header, :$missing-signature)),
                over-documented     => Map.new((:$non-local, :$non-method, :$doesn't-exist)),
                all-good            => [(-)] $local, $lacks-introspection, $native-code, $missing-header,
                                             $missing-signature, |%over-documented.values)))))
}

#TODO doc here
sub classify-method(Mu $method, $type-name, List $ignored-methods) {
    when $method.name ∈ $ignored-methods                                 { 'ignored' };
    # Some builtins don't support the introspection we need, mostly ones that call ForeignCode
    # (which includes NQP methods).  ForeignCode methods typically have the name `<anon>`
    CATCH {  when X::Method::NotFound {
                  when .method ~~ 'roles' | 'candidates' { return 'lacks-introspection' } } }
    when $method.name eq '<anon>'                                        { 'native-code' };

    # we treat a multi method as local if any of it's variants are in the Type's package
    my $packages = (?$method.candidates ?? $method.candidates !! $method).map(*.package).cache;
    when ?any($packages.map({ try .isa($type-name)}))      { 'local'}
    when ?any($packages.map({ try $_ ~~ ::($type-name)}))  { 'local'}
    when  any($packages) ~~ any(::($type-name).^roles)     { 'from-a-role' }
    # For low level types, === won't work, so use string comparison
    when  $packages.head.^name eq 'Any'                            { 'from-any' }
    when  $packages.head.^name eq 'Mu'                             { 'from-mu' }
    default                                                { 'from-other' }
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
        ~( if %uncheckable<lacks-introspection> {
            "{+%uncheckable<lacks-introspection>} method without introspection:\n".&pluralize('method').indent(2)
            ~ (%uncheckable<lacks-introspection>.keys.sort.join("\n").indent(4) ~ "\n")})
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
    # TODO: Add stats for most skipped methods
    has Map $!totals;
    has Map $!under-documented;
    has Map $!over-documented;
    has Map $!false-positives;

    submethod BUILD() {
        # Maps with scallar values gives interior mutiablity but guarentees we can't typo keys
        $!totals := Map.new(
            ( types   => Map.new((skip => $=0, pass => $=0, fail => $=0)),
              methods => Map.new((skip => $=0, pass => $=0, ignored => $=0,
                                  under => $=0, over => $=0, false-positives => $=0))));
        $!under-documented := Map.new(
            ( sums                       => Map.new((missing-header => $=0, missing-signature => $=0)),
              missing-per-type           => BagHash.new(),
              times-missing-by-method    => BagHash.new()));
        $!over-documented  := Map.new(
            ( sums                       => Map.new((doesn't-exist => $=0, non-method => $=0, non-local => $=0)),
              missing-per-type           => BagHash.new(),
              times-overdocked-by-method => BagHash.new()));
        $!false-positives := Map.new(
            ( from-a-role => $=0, from-any => $=0, from-mu => $=0, from-other => $=0, anon => $=0));
    }
#  (:$from-a-role, :$anon, :$from-any, :$from-mu)
    submethod update-false-postives(:%false-positives) {
        for %false-positives.kv {$!false-positives{$^key} += +$^value};
    }

    submethod fmt-false-positives() {
        my $*total = [+] $!false-positives.values;
        qq:to/EOF/

         OVERINCLUSIVE INTROSPECTION:
         ############################

         Methods listed as :local but actually from
         ==========================================
         ...a role            { $!false-positives<from-a-role>.&fmt-with-percent-of('total')}
         ...Mu                { $!false-positives<from-mu>.&fmt-with-percent-of('total')}
         ...Any               { $!false-positives<from-any>.&fmt-with-percent-of('total')}
         ...some other type   { $!false-positives<from-other>.&fmt-with-percent-of('total')}
        EOF
    }

    submethod count-uncheckable-type() { $!totals<types><skip>++ }

    submethod fmt-header() {
        q:to/EOF/

         ##################
         #    SUMMARY     #
         ##################
        EOF
    }
    submethod update-totals(:$ignored, :$all-good, :%under-documented, :%over-documented,
                            :%false-positives, :%uncheckable) {
        %uncheckable.values ∪ |%under-documented.values ∪ |%over-documented.values
                ?? $!totals<types><fail>++
                !! $!totals<types><pass>++;
        given $!totals<methods> {
            .<skip>            += +%uncheckable.values».List.flat;
            .<ignored>         += +$ignored;
            .<pass>            += +$all-good;
            .<under>           += +%under-documented.values».List.flat;
            .<over>            += +%over-documented.values».List.flat;
            .<false-positives> += +%false-positives.values».List.flat;
        }
    }

    submethod fmt-totals() {
        my (:%types, :%methods) := $!totals;
        do { my $*checked  = %types<pass> + %types<fail>;
             my $*detected = %types<skip> + $*checked;
             qq:to/EOF/

              Total types processed:
              ======================
              documented types detected:   {sprintf('%4d', $*detected)}
              types checked:               {$*checked.&fmt-with-percent-of('detected')}
              types skipped:               {%types<skip>.&fmt-with-percent-of('detected')}
              problems found:              {%types<fail>.&fmt-with-percent-of('checked')}
              no problems found:           {%types<pass>.&fmt-with-percent-of('checked')}
             EOF
           } ~ do {
            my $*checked  = %methods<pass> + %methods<over> + %methods<under>;
            my $*detected = %methods<skip> + $*checked;
            qq:to/EOF/

             Total methods processed:
             ========================
             documented methods detected:    { sprintf('%4d', $*detected)}
             unprocessable methods skipped:  { (%methods<skip>).&fmt-with-percent-of('detected')}
             explicitly ignored methods:     { %methods<ignored>.&fmt-with-percent-of('detected')}
             methods checked:                { $*checked.&fmt-with-percent-of('detected')}
             over-documented methods:        { %methods<over>.&fmt-with-percent-of('checked')}
             under-documented methods:       { %methods<under>.&fmt-with-percent-of('checked')}
             false-positives skipped:        { %methods<false-positives>}
             problem-free methods:           { %methods<pass>.&fmt-with-percent-of('checked')}
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
        my $*total = %sums<missing-header> + %sums<missing-signature>;
        my $top-missing = %times-missing-by-method
                              .grep(*.value ≥ $missing_method_threshold)
                              .sort({.value, .key})
                              .cache;
        my $top-types = %missing-per-type.sort({.value, .key}).tail($most_missing_list_length).cache;

        qq:to/EOF/

         UNDER-DOCUMENTED:
         #################

         (Potentially) under-documented methods:
         =======================================
         total under documented:    {sprintf('%4d', $*total)}
         missing methods:           {%sums<missing-header>.&fmt-with-percent-of('total')}
         methods with no signature: {%sums<missing-signature>.&fmt-with-percent-of('total')}
        EOF
        ~ (if $top-missing {
                  ~ "\nMethods missing from 20+ types:\n".indent(1)
                  ~   "===============================\n".indent(1)
                  ~ self!fmt-top-methods($top-missing)
              })
        ~ (if $top-types.elems {
                  ~ "\nTypes with the most missing methods:\n".indent(1)
                  ~   "====================================\n".indent(1)
                  ~ $top-types.map({ sprintf(" %-*s %-5d",
                                             $top-types.&max-len, .key,
                                             .value)}).join("\n") ~ "\n"})
    }

    submethod update-over-documented(:%over-documented, :%file (:$type-name, *%)) {
        $!over-documented<sums>{.key} += .value.elems for %over-documented.pairs;
        $!over-documented<missing-per-type>{$type-name} += +%over-documented<doesn't-exist>;
        for %over-documented<doesn't-exist>.keys -> $method {
            $!over-documented<times-overdocked-by-method>.add($method)};
    }

    submethod fmt-over-documented() {
        my (:%sums, :%missing-per-type, :%times-overdocked-by-method) := $!over-documented;

        my $*total = %sums<non-local> + %sums<non-method> + %sums<doesn't-exist>;
        my $top-types = %missing-per-type.sort({.value, .key}).tail($most_overdocked_list_length).cache;
        my $top-overdocked = %times-overdocked-by-method.grep(*.value ≥ $overdocked_method_threshold).cache;
        qq:to/EOF/

         OVER-DOCUMENTED:
         ################

         Total over-documented methods:
         ==============================
         total over documented:    {sprintf('%4d', $*total)}
         non-local methods:        {%sums<non-local>.&fmt-with-percent-of('total')}
         non-method routines:      {%sums<non-method>.&fmt-with-percent-of('total')}
         non-existent methods:     {%sums<doesn't-exist>.&fmt-with-percent-of('total')}
        EOF
        ~ (if $top-overdocked {
                  ~ "\nOverdocumented methods in 20+ types:\n".indent(1)
                  ~   "===============================\n".indent(1)
                  ~ self!fmt-top-methods($top-overdocked)
              })
        ~ (if $top-types.elems ≥ 3 {
                  "\n"
                  ~ "Types with the most over-documented methods:\n".indent(1)
                  ~ "============================================\n".indent(1)
                  ~ ($top-types.map({ sprintf(" %-*s %-5d\n",
                                              $top-types.&max-len, .key,
                                              .value)}).join)})
    }


    submethod !fmt-top-methods($top-methods) {
                  ~ $top-methods.sort(*.value).map({ sprintf(" %-*s    %3d",
                                                             $top-methods.&max-len, .key,
                                                             .value)}).join("\n") ~ "\n"
                  ~ ('-' x ($top-methods.&max-len + 7)).indent(1) ~ "\n"
                  ~ "TOTAL".indent($top-methods.&max-len - 1)
                  ~ $top-methods.map(*.value).sum.&fmt-with-percent-of('total') ~ "\n"
    }

    #| Returns the length of the longest key in a list of pairs
    sub max-len(List $pairs --> Int) { $pairs.max(*.key.chars).key.chars }

    #| Dynamically format a number as both a raw number and a percent of a dynamic variable
    sub fmt-with-percent-of($num, $name) { # pretty hacky, should be a macro once Raku-AST lands
        #TODO: FixMe using a named slurpy `*%h`
        sprintf("%4d (%4.1f%% of $name)", $num, 100 × $num/(CALLERS::("\$*$name") || 1))
    }
}

#| Parses a Pod6 document and returns all methods mentioned in a header or given a signature
grammar MethodDoc {
    token TOP { | [<in-header>     { make (in-header      => ~$<in-header><method>) }
                | <with-signature> { make (with-signature => ~$<with-signature><method>) } ]}

    token with-signature { <ws> ['multi' <ws>]? <keyword> <ws> <method> '(' .+ }
    token in-header      { '=head' \d? <ws> <keyword> <ws> <method> }
    token keyword        { ['method' | 'routine'] }
    ## TODO use `sym` to simplify
    token method         { <[-'\w]>+ }
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
