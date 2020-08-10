#! /usr/bin/env raku
use v6;
use Telemetry;
use Test;

class Summary     {...}
class Report      {...}
grammar MethodDoc {...}

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
    Str :e(:$exclude),                                   #= Exclude files or directories matching Regex
    Str :O(:$only),                                      #= Include ONLY files or directories matching Regex
    ReportCsv  :report(:$r)  = 'all',                    #= Comma-separated list of documentation types to display
    SummaryCsv :summary(:$s) = 'all',                    #= Comma-separated list of summary types to display
    Bool :h(:$help),                                     #= Display this message and exit
    Str :i(:$ignore) = "$util_dir/ignored-methods.txt",  #= Path to file with methods to skip
) {
    when $help { USAGE }
    my $reports-to-print  = any(|(S/'all'/skip,pass,fail,err,over,under/ with $r).split(',')».trim);
    my $summaries-to-print = any(|(S/'all'/totals,over,under/         with $s).split(',')».trim);
    my $summary = Summary.new;

    for $input-path.&process-pod6($exclude, $only, ignored-types => EVALFILE($ignore)).hyper.map(
        -> (:%file, :%methods (:%local, :%uncheckable, :%over-documented, :%under-documented)) {

        when %file<no-type-found> { if $reports-to-print ~~ 'err' { Report::fmt-bad-file(%file<path>)}}
        when %file<uncheckable> { $summary.count-uncheckable-type;
                                  (if $reports-to-print ~~ 'skip' { Report::fmt-skipped(:%file) }) }

        $summary.update-totals(:%local, :%uncheckable, :%under-documented, :%over-documented);
        $summary.update-over-documented(:%over-documented,   :%file);
        $summary.update-under-documented(:%under-documented, :%file);

        my $status = (%uncheckable ∪  |%under-documented.values ∪ |%over-documented.values ?? '✗' !! '✔');
        (if (($reports-to-print ~~ 'pass')  && $status eq '✔')
         || (($reports-to-print ~~ 'skip')  && ?%uncheckable)
         || (($reports-to-print ~~ 'under') && ?%under-documented.values)
         || (($reports-to-print ~~ 'over')  && ?%over-documented.values) {
             "\n$status {%file<type-name>} – documented at ⟨%file<path>.IO}⟩\n"
         })

         ~ (if $reports-to-print ~~ ('skip')  { Report::fmt(:%uncheckable) })
         ~ (if $reports-to-print ~~ ('under') { Report::fmt(:%under-documented) })
         ~ (if $reports-to-print ~~ ('over')  { Report::fmt(:%over-documented) });
    }) { .print };

    if $summaries-to-print !~~ 'none'   { print $summary.fmt-header };
    if $summaries-to-print ~~  'totals' { print $summary.fmt-totals };
    if $summaries-to-print ~~  'under'  { print $summary.fmt-under-documented };
    if $summaries-to-print ~~  'over'   { print $summary.fmt-over-documented };
}

#| Process a directory of Pod6 files by recursively processing each file
multi process-pod6($path where {.IO ~~ :d}, $exclude, $only, :%ignored-types --> List) {
    |(lazy $path.dir ==> grep( -> $file { all( (with $exclude { $file.basename !~~ /<$exclude>/ }),
                                               (with $only    { $file.basename  ~~ /<$only>/    }),
                                               True )})
                     ==> map({ |process-pod6($^next-path, $exclude, $only, :%ignored-types )}))
}

#| Process a Pod6 file by parsing with the MethodDoc grammar and then comparing
#| the documented methods against the methods visible via introspection
multi process-pod6($path, $?, $?, :%ignored-types  --> List) {
    when $path !~~ /.*'doc/Type/'(.*).pod6/ { (%(file => Map.new((no-type-found => True,  :$path))), )}
    my $type-name = (S/.*'doc/Type/'(.*).pod6/$0/).subst(:g, '/', '::') with $path;

    try { ::($type-name).raku && ::($type-name).^methods;
          # if we're at a low enough level that this amount of introspection fails, skip the type
          CATCH { default { return (%(file => Map.new((uncheckable => True, :$type-name, :$path))), )}}
    }

    # TODO: do this with classify;
    my $uncheckable-methods = SetHash.new();
    # Confusingly, many methods returned by ^methods(:local) are *not* local, so we filter by package
    my Set $local-methods = (::($type-name).^methods(:local).grep(-> $method {
        # Some builtins don't support the introspection we need, mostly ones that call ForeignCode
        # (which includes NQP methods).  ForeignCode methods typically have the name `<anon>`
        CATCH { default { $uncheckable-methods{~$method.name}++ unless $method.name eq '<anon>' } }
        try { $method.package.isa($type-name) } // $method.package ~~ ::($type-name)
    })».name  (-) %ignored-types{$type-name}) ;
    # TODO: add support for %ignored-types<GLOBAL> ^^^^^

    my (:@in-header, :@with-signature) :=  $path.IO.lines
                                                   .map({ MethodDoc.parse($_).made })
                                                   .grep(*.defined)
                                                   .classify(*.key, :as{.value});

    my Set $missing-header    = $local-methods (-) Set.new(@in-header);
    my Set $missing-signature = $local-methods (-) @with-signature (-) $missing-header;
    (@in-header (-) $local-methods).keys.classify(-> $method {
        # if ^find_method finds it, it's *somewhere* in the inheritance graph, just not local
        when try {::($type-name).^find_method($method).defined} { 'non-local' }
        # If the type matches first item in the signature, then it's a sub the type can call with .&…
        when try { any(&::($method).candidates.map(-> $a {::($type-name) ~~ $a.signature.params.head.type}))} {
             'non-method'
         }
        "doesn't-exist"
    },
    :into( my %over-documented = doesn't-exist => [], non-local => [], non-method => [] ));

    (file => Map.new((:$type-name, :$path)),
     methods => Map.new(( local            => $local-methods,
                          uncheckable      => $uncheckable-methods.Set,
                          under-documented => Map.new((:$missing-header, :$missing-signature)),
                          :%over-documented, ))),
}

# Formats reports for individual Types (displayed with --report)
class Report {
    our sub fmt-skipped(:%file (:$type-name, :$path, *%)) {
        "\n∅ {$type-name} – documented at  ⟨{$path.IO}⟩\n  Skipped as uncheckable\n"
    }
    our sub fmt-bad-file($path) {
        "\n! ERR could not process file at ⟨{$path.IO}⟩\n  Does it contain documentation for a Raku type?\n"
    }

    our proto fmt(|) {*}

    multi fmt(:$uncheckable) {
        ( if $uncheckable {
            "{+$uncheckable} uncheckable method:\n".&pluralize('method').indent(2)
            ~ ($uncheckable.keys.sort.join("\n").indent(4) ~ "\n")})
    }
    multi fmt(:%over-documented) {
        my (:@non-local, :@non-method, :@doesn't-exist) := %over-documented;
        ~( if @non-local {
             ("{+@non-local} non-local method with documentation:\n").&pluralize('method').indent(2)
             ~ @non-local.sort.join("\n").indent(4) ~ "\n"})
        ~( if @non-method {
             ("{+@non-method} non-method with documentation:\n").&pluralize('non-method').indent(2)
             ~ @non-method.sort.join("\n").indent(4) ~ "\n"})
        ~( if @doesn't-exist {
             ("{+@doesn't-exist} non-existing method with documentation:\n").&pluralize('method').indent(2)
             ~ @doesn't-exist.sort.join("\n").indent(4) ~ "\n"})
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

    submethod BUILD() {
        $!totals           := Map.new(( types                      => %(:0skip, :0pass, :0fail),
                                        methods                    => %(:0skip, :0pass, :0under, :0over)));
        $!under-documented := Map.new(( sums                       => %(:0missing-header, :0missing-signature),
                                        missing-per-type           => BagHash.new(),
                                        times-missing-by-method    => BagHash.new()));
        $!over-documented  := Map.new(( sums                       => %(:0doesn't-exist, :0non-method, :0non-local),
                                        missing-per-type           => BagHash.new(),
                                        times-overdocked-by-method => BagHash.new()));
    }

    submethod count-uncheckable-type() { $!totals<types><skip>++ }

    submethod fmt-header() {
        q:to/EOF/

         ##################
         #    SUMMARY     #
         ##################
        EOF
    }

    submethod update-totals(:%local, :%uncheckable, :%under-documented, :%over-documented) {
        %uncheckable ∪  |%under-documented.values ∪ |%over-documented.values
                ?? $!totals<types><fail>++
                !! $!totals<types><pass>++;

        given $!totals<methods> {
            .<skip>  += +%uncheckable;
            .<under> += +%under-documented.values».List.flat;
            .<over>  +=  +%over-documented.values».List.flat;
            .<pass>  += +%local - ( %uncheckable
                                    + %under-documented.values».List.flat
                                    +  %over-documented.values».List.flat );
        }
    }

    submethod fmt-totals() {
        my (:%types, :%methods) := $!totals;
        do { my $*checked  = %types<pass> + %types<fail>;
             my $*detected = %types<skip> + $*checked;
             qq:to/EOF/

              Total types processed:
              ======================
              types detected:   {sprintf('%4d', $*detected)}
              types checked:    {$*checked.&fmt-with-percent-of('detected')}
              types skipped:    {%types<skip>.&fmt-with-percent-of('detected')}
              problems found:   {%types<fail>.&fmt-with-percent-of('checked')}
              no problems found:{%types<pass>.&fmt-with-percent-of('checked')}
             EOF
           } ~ do {
            my $*checked  = %methods<pass> + %methods<over> + %methods<under>;
            my $*detected = %methods<skip> + $*checked;
            qq:to/EOF/

             Total methods processed:
             ========================
             methods detected:  {sprintf('%4d', $*detected)}
             methods checked:   {      $*checked.&fmt-with-percent-of('detected')}
             methods skipped:   { %methods<skip>.&fmt-with-percent-of('detected')}
             over-documented:   { %methods<over>.&fmt-with-percent-of('checked')}
             under-documented:  {%methods<under>.&fmt-with-percent-of('checked')}
             no problems found: { %methods<pass>.&fmt-with-percent-of('checked')}
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
        my $top-missing = %times-missing-by-method.grep(*.value ≥ $missing_method_threshold).cache;
        my $top-types = %missing-per-type.sort(*.value).tail($most_missing_list_length).cache;

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
        $!over-documented<sums>{.key}        += .value.elems for %over-documented.pairs;
        $!over-documented<missing-per-type>{$type-name} += +%over-documented<doesn't-exist>;
        for %over-documented<doesn't-exist>.values -> $method {
            $!over-documented<times-overdocked-by-method>.add($method)};
    }

    submethod fmt-over-documented() {
        my (:%sums, :%missing-per-type, :%times-overdocked-by-method) := $!over-documented;
        my $*total = %sums<non-local> + %sums<non-method> + %sums<doesn't-exist>;
        my $top-types = %missing-per-type.sort(*.value).tail($most_overdocked_list_length).cache;
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
