#! /usr/bin/env raku
use v6;
use Telemetry;
use Test;

class Summary {...}
grammar MethodDoc {...}

subset ReportCsv  of Str:D where *.split(',')».trim ⊆ <over under skip pass fail all none>;
subset SummaryCsv of Str:D where *.split(',')».trim ⊆ <totals over under all none yes>;

#| Scan a pod6 file or directory of pod6 files for over- and under-documented methods
sub MAIN(
    IO(Str) $input-path      = './doc/Type/',     #= Path to the file or directory to check
    Str :e(:$exclude)        = ".git",            #= Comma-separated list of files/directories to ignore
    ReportCsv :r(:$report)   = 'all',             #= Comma-separated list of documentation types to display
    SummaryCsv :summary(:$s) = 'all',             #= Whether to display summary statistics
    Bool :h(:$help),                              #= Display this message and exit
    :i(:$ignore) = './util/ignored-methods.txt'   #= Path to file with methods to skip
) {
    when $help { USAGE }
    my $report-items  = any(|$report.split(',')».trim);
    my $summary-items = any(|$s.split(',')».trim);
    my $summary = Summary.new;

    for $input-path.&process-pod6($exclude, ignored-types => EVALFILE($ignore)).hyper.map(
        -> $pod6 {
        my (:$type-name, :$path, :%local-methods, :$uncheckable, :%uncheckable-methods, :%over-documented, :%under-documented) := $pod6;
        when $uncheckable.so {
            $summary.count-uncheckable-type;
            (if $report-items ~~ ('all' | 'skip') {
                    "\n∅ {$type-name} – documented at  ⟨{$path.IO}⟩\n  Skipped as uncheckable\n" });
        }
        $summary.update-totals(:%local-methods, :%uncheckable-methods, :%under-documented, :%over-documented);
        $summary.update-over-documented(:%over-documented, :$type-name);
        $summary.update-under-documented(:%under-documented, :$type-name);

        my $status = (%uncheckable-methods ∪  |%under-documented.values ∪ |%over-documented.values
                      ?? '✗'
                      !! '✔');

        (if (($report-items ~~ 'all' | 'pass')  && $status eq '✔')
         || (($report-items ~~ 'all' | 'skip')  && ?%uncheckable-methods)
         || (($report-items ~~ 'all' | 'under') && ?%under-documented.values)
         || (($report-items ~~ 'all' | 'over')  && ?%over-documented.values) {
          "\n$status {$type-name} – documented at ⟨{$path.IO}⟩\n"
         })

         ~ (if $report-items ~~ ('all' | 'skip') && ?$uncheckable  { fmt-report(:$uncheckable) })
         ~ (if $report-items ~~ ('all' | 'under')                  { fmt-report(:%under-documented)})
         ~ (if $report-items ~~ ('all' | 'over')                   { fmt-report(:%over-documented)});
    }) { .print };

    if $summary-items !~~ 'none'          { print $summary.fmt-header };
    if $summary-items ~~ 'all' | 'totals' { print $summary.fmt-totals };
    if $summary-items ~~ 'all' | 'under'  { print $summary.fmt-under-documented };
    if $summary-items ~~ 'all' | 'over'   { print $summary.fmt-over-documented };
}


#| Process a directory of Pod6 files by recursivly processing each file
multi process-pod6($path where {.IO ~~ :d}, $exclude, :%ignored-types --> List) {
    |(lazy $path.dir
               ==> grep({ .basename ~~ none($exclude.split(',')».trim) })
               ==> map({ |process-pod6($^next-path, $exclude, :%ignored-types )}))
}

class Pod6 {
    has Str $.type-name;
    has IO::Path $.path;
    has Set $.local-methods;
    has Bool $.uncheckable;
    has Set $.uncheckable-methods;
    has Map $.over-documented;
    has Map $.under-documented;
}

#| Process a Pod6 file by parsing with the MethodDoc grammar and then comparing
#| the documented methods against the methods visible via introspection
multi process-pod6($path, $?, :%ignored-types  --> List) {
    # TODO: error if cannot do vvvvv
    my $type-name = (S/.*'doc/Type/'(.*).pod6/$0/).subst(:g, '/', '::') with $path;

    try { ::($type-name).raku;
          ::($type-name).HOW.raku;
          ::($type-name).^methods;
          # if we're at a low enough level that this amount of introspection fails, skip the type
          CATCH { default { return (%( uncheckable => True, :$type-name, path => $path), )}}
    }

    my $uncheckable-methods = SetHash.new();
    # TODO: do this with clasify;
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
    my Set $missing-signature     = $local-methods (-) @with-signature (-) $missing-header;
    (@in-header (-) $local-methods (-) Set.new('', Any)).keys.classify(-> $method {
        # if ^find_method finds it, it's *somewhere* in the inheritance graph, just not local
        when try {::($type-name).^find_method($method).defined} { 'non-local' }
        # If the type matches first item in the signiture, then it's a sub the type can call with .&…
        when try { any(&::($method).candidates.map(-> $a {::($type-name) ~~ $a.signature.params.head.type}))} {
             'non-method-sub'
         }
        "doesn't-exist"
    },
    :into( my %over-documented = doesn't-exist => [], non-local => [], non-method-sub => [] )
);

   (Pod6.new(:$type-name,
              :$path,
              :$local-methods,
              uncheckable-methods => $uncheckable-methods.Set,
              :%over-documented,
              under-documented => Map.new((:$missing-header, :$missing-signature))),)

}

#| Provide dynamic usage info, including default values assigned in MAIN
sub USAGE() {
    my &fmt-param = { $^a ~ (' ' x (20 - $^a.chars) ~ $^b.WHY ~ (with $^b.default { " [default: {.()}]"})) }
    # TODO: add info about meaning of output for over- and under-documented methods.

    print do given &MAIN.signature.params {
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

#| Provide error messages that inform the user what unsupported paramater they passed
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

#| Helper sub to dynamically format a number as both a raw number and
#| as a percent of a dynamic variable
sub fmt-with-percent-of($num, $name) { # pretty hacky, should be a macro once Raku-AST lands
    sprintf("%4d (%4.1f%% of $name)", $num, 100 × $num/CALLER::OUTER::("\$*$name"))
}

#| Helper sub that returns the length of the longest key in a list of pairs
sub max-len(List $pairs --> Int) { $pairs.max(*.key.chars).key.chars }

#| Appends an 's' to the provided $noun if the closest preceding number in $phrase is ≥ 2
sub pluralize(Str $phrase, Str $noun --> Str) {
    $phrase ~~ /(\d+) \D* $noun/;
    +$0 == 1 ?? $phrase !! $phrase.subst(/$noun/, $noun ~ 's')
}

multi fmt-report(:$uncheckable) {  "{+$uncheckable} uncheckable method:\n".&pluralize('method').indent(2)
                                   ~ ($uncheckable.join("\n").indent(4) ~ "\n")
}

multi fmt-report(:%over-documented) {
    my (:@non-local, :@non-method-sub, :@doesn't-exist) := %over-documented;
    ~( if @non-local {
         ("{+@non-local} non-local method with documentation:\n").&pluralize('method').indent(2)
         ~ @non-local.sort.join("\n").indent(4) ~ "\n"})
    ~( if @non-method-sub {
         ("{+@non-method-sub} non-method with documentation:\n").&pluralize('non-method').indent(2)
         ~ @non-method-sub.sort.join("\n").indent(4) ~ "\n"})
    ~( if @doesn't-exist {
         ("{+@doesn't-exist} non-existing method with documentation:\n").&pluralize('method').indent(2)
         ~ @doesn't-exist.sort.join("\n").indent(4) ~ "\n"})
}

multi fmt-report(:%under-documented) {
    my (:%missing-header, :%missing-signature) := %under-documented;
    ~ ( if +%missing-header {
         "{+%missing-header} missing method:\n".&pluralize('method').indent(2)
         ~ %missing-header.keys.sort.join("\n").indent(4) ~ "\n" })
    ~ ( if %missing-signature {
         ("{+%missing-signature} method without signature:\n"
             ).&pluralize('method').&pluralize('signature').indent(2)
         ~ %missing-signature.keys.sort.join("\n").indent(4) ~ "\n"})
}


#| Manages the collection and formatting of summary statistics (displayed with --summary)
class Summary {
    has Map $!totals;
    has Map $!under-documented;
    has Map $!over-documented;

    submethod BUILD() {
        $!totals           := Map.new(( types   => %(:0skip, :0pass, :0fail),
                                        methods => %(:0skip, :0pass, :0under, :0over)));
        $!under-documented := Map.new(( sums    => %(:0doesn't-exist, :0non-method-sub, :0non-local),
                                        types   => BagHash.new(),
                                        methods => BagHash.new()));
        $!over-documented  := Map.new(( sums    => %(:0doesn't-exist, :0non-method-sub, :0non-local),
                                        types   => BagHash.new()));
    }

    submethod count-uncheckable-type() { $!totals<types><skip>++ }

    submethod fmt-header() {
        q:to/EOF/
         ##################
         #    SUMMARY     #
         ##################
        EOF
    }

    submethod fmt-totals() {
        my (:%types, :%methods) := $!totals;
        do { my $*checked  = %types<pass> + %types<fail>;
             my $*detected = %types<skip> + $*checked;
             qq:to/EOF/

              Total types processed:
              ======================
              types detected:    $*detected
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
             methods detected:  $*detected
             methods checked:   {$*checked.&fmt-with-percent-of('detected')}
             methods skipped:   {%methods<skip>.&fmt-with-percent-of('detected')}
             over-documented:   {%methods<over>.&fmt-with-percent-of('checked')}
             under-documented:  {%methods<under>.&fmt-with-percent-of('checked')}
             no problems found: {%methods<pass>.&fmt-with-percent-of('checked')}
            EOF
        }
    }

    submethod fmt-under-documented() {
        my (:%sums, :%methods, :%types) := $!under-documented;
        my $*total = %sums<missing-header> + %sums<missing-signature>;
        my $top-missing = %methods.grep(*.value ≥ 20).cache;
        my $top-types = %types.sort(*.value).tail(5).cache;
        qq:to/EOF/

         UNDER-DOCUMENTED:
         #################

         (Potentially) under-documented methods:
         =======================================
         total under documented:    $*total
         missing methods:           {%sums<missing-header>.&fmt-with-percent-of('total')}
         methods with no signature: {%sums<missing-signature>.&fmt-with-percent-of('total')}
        EOF
        ~ (if $top-missing {
                  "\n"
                  ~ "Methods missing from 20+ types:\n".indent(1)
                  ~ "===============================\n".indent(1)
                  ~ $top-missing.sort(*.value).map({ sprintf(" %-*s    %d",
                                                             $top-missing.&max-len, .key,
                                                             .value)}).join("\n") ~ "\n"
                  ~ ('-' x ($top-missing.&max-len + 7)).indent(1) ~ "\n"
                  ~ "TOTAL".indent($top-missing.&max-len - 1)
                  ~ $top-missing.map(*.value).sum.&fmt-with-percent-of('total') ~ "\n"
              })
        ~ (if $top-types.elems ≥ 3 {
                  "\n"
                  ~ " Types with the most missing methods:\n"
                  ~ " ====================================\n"
                  ~ $top-types.map({ sprintf(" %-*s %-5d",
                                             $top-types.&max-len, .key,
                                             .value)}).join("\n") ~ "\n"})
    }

    submethod fmt-over-documented() {
        my (:%sums, :%types) := $!over-documented;
        my $*total = %sums<non-local> + %sums<non-method-sub> + %sums<doesn't-exist>;
        my $top-types = %types.sort(*.value).tail(5).cache;
        qq:to/EOF/

         OVER-DOCUMENTED:
         ################

         Total over-documented methods:
         ==============================
         total over documented:     $*total
         non-local methods:        {%sums<non-local>.&fmt-with-percent-of('total')}
         non-method routines:      {%sums<non-method-sub>.&fmt-with-percent-of('total')}
         non-existent methods:     {%sums<doesn't-exist>.&fmt-with-percent-of('total')}
        EOF
        ~ (if $top-types.elems ≥ 3 {
                  "\n"
                  ~ "Types with the most over-documented methods:\n".indent(1)
                  ~ "============================================\n".indent(1)
                  ~ ($top-types.map({ sprintf(" %-*s %-5d\n",
                                              $top-types.&max-len, .key,
                                              .value)}).join)})
    }

    submethod update-totals(:%local-methods, :%uncheckable-methods, :%under-documented, :%over-documented) {
        %uncheckable-methods ∪  |%under-documented.values ∪ |%over-documented.values
                ?? $!totals<types><fail>++
                !! $!totals<types><pass>++;
        my $under-count = +.<missing-header> + .<missing-signature>  with %under-documented;
        my $over-count  = +.<non-local> + .<non-method-sub> + .<doesn't-exist> with %over-documented;
        $!totals<methods><skip>  += +%uncheckable-methods;
        $!totals<methods><under> += $under-count;
        $!totals<methods><over>  += $over-count;
        $!totals<methods><pass>  += +%local-methods - (%uncheckable-methods + $under-count + $over-count)
    }

    submethod update-under-documented(:%under-documented, :$type-name) {
        $!under-documented<sums>{.key} += .value.elems for %under-documented.pairs;
        $!under-documented<methods>.add($_)         for %under-documented<missing-header>.keys;
        $!under-documented<types>{$type-name}    += %under-documented<missing-header>.elems;
    }

    submethod update-over-documented(:%over-documented, :$type-name) {
        $!over-documented<sums>{.key}                += .value.elems for %over-documented.pairs;
        $!over-documented<types>{$type-name}  += %over-documented<doesn't-exist>.elems;
    }
}

grammar MethodDoc {
    token TOP { [<in-header>  | <with-signature>]
                { with $<in-header><method>      { make (in-header      => ~$_) }
                  with $<with-signature><method> { make (with-signature => ~$_) }}}

    token with-signature { <ws> ['multi' <ws>]? <keyword> <ws> <method> '(' .* }
    token in-header      { '=head' \d? <ws> <keyword> <ws> <method> }
    token keyword        { ['method' | 'routine'] }
    token method         { <[-'\w]>+ }
}
