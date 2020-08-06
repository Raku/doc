#! /usr/bin/env raku
use v6;
use Telemetry;
use Test;

grammar MethodDoc {
    token TOP { [<in-header>  | <with-signature>]
                { make ($<in-header><method>, $<with-signature><method>).map({ ~($_ // ()) }) } }

    token with-signature { <ws> ['multi' <ws>]? <keyword> <ws> <method> '(' .* }
    token in-header      { '=head' \d? <ws> <keyword> <ws> <method> }
    token keyword        { ['method' | 'routine'] }
    token method         { <[-'\w]>+ }
}

# TODO: Reorder subs

sub USAGE() {
    my &fmt-param = { $^a ~ (' ' x (20 - $^a.chars) ~ $^b.WHY ~ (with $^b.default { " [default: {.()}]"})) }
    # TODO: add info about meaning of output for over- and under-documented methods.

    print do given &MAIN.signature.params {
      "Usage: ./{$*PROGRAM.relative} [OPTION]... [SRC]\n"
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

subset ReportCsv  of Str:D where *.split(',')».trim ⊆ <over under skip pass fail all none>;
subset SummaryCsv of Str:D where *.split(',')».trim ⊆ <totals over under all none yes>;

multi GENERATE-USAGE(&main, |capture) {
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

#| Scan a pod6 file or directory of pod6 files for over- and under-documented methods
sub MAIN(
    IO(Str) $src             = './doc/Type/',     #= Path to the file or directory to check
    Str :e(:$exclude)        = ".git",            #= Comma-separated list of files/directories to ignore
    ReportCsv :r(:$report)   = 'all',             #= Comma-separated list of documentation types to display
    SummaryCsv :s(:$summary) = 'all',             #= Whether to display summary statistics
    Bool :h(:$help),                              #= Display this message and exit
    :i(:$ignore) = './util/ignored-methods.txt'   #= Path to file with methods to skip
) {
    when $help { USAGE }
    my $report-items  = any(|$report.split(',')».trim);
    my $summary-items = any(|$summary.split(',')».trim);

    # TODO: Comment
    my %summary  :=
        Map.new(%{
            totals           => Map.new(( types   => %(:0skip, :0pass, :0fail),
                                          methods => %(:0skip, :0pass, :0under, :0over))),
            under-documented => Map.new(( sums    => %(:0doesn't-exist, :0non-method-sub, :0non-local),
                                          types   => BagHash.new(),
                                          methods => BagHash.new())),
            over-documented  => Map.new(( sums    => %(:0doesn't-exist, :0non-method-sub, :0non-local),
                                          types   => BagHash.new()))
    });

    my $output = $(process($src, EVALFILE($ignore), $exclude)).map( {
        when .<uncheckable>.so {
            %summary<totals><types><skip>++;
            (if $report-items ~~ ('all' | 'skip') {
                    "\n∅ {.<type-name>} – documented at  ⟨{.<path>.IO}⟩\n  Skipped as uncheckable\n" });
        }
        %summary<totals>.&update-totals($_);
        %summary<under-documented>.&update-under-documented($_);
        %summary<over-documented>.&update-over-documented($_);

        my $status = (.<uncheckable-method> ∪  |.<under-documented>.values ∪ |.<over-documented>.values
                      ?? '✗'
                      !! '✔');

        (if (($report-items ~~ 'all' | 'pass')  && $status eq '✔')
         || (($report-items ~~ 'all' | 'skip')  && ?.<uncheckable-method>)
         || (($report-items ~~ 'all' | 'under') && ?.<under-documented>.values)
         || (($report-items ~~ 'all' | 'over')  && ?.<over-documented>.values) {
          "\n$status {.<type-name>} – documented at ⟨{.<path>.IO}⟩\n"
         })

         ~ (if $report-items ~~ ('all' | 'skip')  { fmt-uncheckable-methods(.<uncheckable>)})
         ~ (if $report-items ~~ ('all' | 'under') { fmt-under-documented-methods(.<under-documented>)})
         ~ (if $report-items ~~ ('all' | 'over')  { fmt-over-documented-methods(.<over-documented>)})
    });
    for $output[] { .print }

    if $summary-items !~~ 'none'          { print fmt-summary-header; }
    if $summary-items ~~ 'all' | 'totals' { print fmt-totals-summary(|%summary<totals>) };
    if $summary-items ~~ 'all' | 'under'  { print fmt-under-documented-summary(|%summary<under-documented>) };
    if $summary-items ~~ 'all' | 'over'   { print fmt-over-documented-summary(|%summary<over-documented>) };
}


sub update-totals(%totals, $data) { given $data {
    .<uncheckable-method> ∪  |.<under-documented>.values ∪ |.<over-documented>.values
                      ?? %totals<types><fail>++
                      !! %totals<types><pass>++;
    my $under-count = +.<missing-header> + .<missing-signature>  with .<under-documented>;
    my $over-count  = +.<non-local> + .<non-method-sub> + .<doesn't-exist> with .<over-documented>;
    %totals<methods><skip>  += +.<uncheckable-method>;
    %totals<methods><under> += $under-count;
    %totals<methods><over>  += $over-count;
    %totals<methods><pass>  += +.<local-methods> - (.<uncheckable-method> + $under-count + $over-count)
}}

sub update-under-documented(%under-documented, $data) {
    %under-documented<sums>{.key} += .value.elems for $data.<under-documented>.pairs;
    %under-documented<methods>.add($data)         for $data.<under-documented><missing-header>.keys;
    %under-documented<types>{$data.<type-name>}    += $data.<under-documented><missing-header>.elems;
}

sub update-over-documented(%over-documented, $data) {
    %over-documented<sums>{.key}                += .value.elems for $data.<over-documented>.pairs;
    %over-documented<types>{$data.<type-name>}  += $data.<over-documented><doesn't-exist>.elems;
}

my &fmt-uncheckable-methods = {
    ~ ( if $_ {  "{+$_} uncheckable method:\n".&pluralize('method').indent(2)
                 ~ ($_.join("\n").indent(4) ~ "\n") } )
}

my &fmt-under-documented-methods = {
    ~ ( if +.<missing-header> {
         "{+.<missing-header>} missing method:\n".&pluralize('method').indent(2)
         ~ .<missing-header>.keys.sort.join("\n").indent(4) ~ "\n" })
    ~ ( if .<missing-signature> {
         ("{+.<missing-signature>} method without signature:\n"
             ).&pluralize('method').&pluralize('signature').indent(2)
         ~ .<missing-signature>.keys.sort.join("\n").indent(4) ~ "\n"})
}

my &fmt-over-documented-methods = {
    ~( if .<non-local> {
         ("{+.<non-local>} non-local method with documentation:\n").&pluralize('method').indent(2)
         ~ .<non-local>.sort.join("\n").indent(4) ~ "\n"})
    ~( if .<non-method-sub> {
         ("{+.<non-method-sub>} non-method with documentation:\n").&pluralize('non-method').indent(2)
         ~ .<non-method-sub>.sort.join("\n").indent(4) ~ "\n"})
    ~( if .<doesn't-exist> {
         ("{+.<doesn't-exist>} non-existing method with documentation:\n").&pluralize('method').indent(2)
         ~ .<doesn't-exist>.sort.join("\n").indent(4) ~ "\n"})
}



sub fmt-with-percent-of($num, $name) { # pretty hacky, should be a macro once Raku-AST lands
    sprintf("%4d (%4.1f%% of $name)", $num, 100 × $num/CALLER::OUTER::("\$*$name"))
}

sub fmt-summary-header() {
    q:to/EOF/
        ##################
        #    SUMMARY     #
        ##################
       EOF
}

sub fmt-totals-summary(:%types, :%methods --> Str) {
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

sub fmt-under-documented-summary(:%sums, :%methods, :%types) {
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
                                                      .value)}).join("\n")
           ~ sprintf("\n %s\n   %*s  %d",
                     '-' x ($top-missing.&max-len + 7),
                     $top-missing.&max-len, "TOTAL",
                     $top-missing.map(*.value).sum) })
    ~ (if $top-types.elems ≥ 3 {
             "\n"
           ~ " Types with the most missing methods:\n"
           ~ " ====================================\n"
           ~ $top-types.map({ sprintf(" %-*s %-5d",
                                      $top-types.&max-len, .key,
                                      .value)}).join("\n") ~ "\n"})
}

sub fmt-over-documented-summary(:%sums, :%types) {
    my $*total = %sums<non-local> + %sums<non-method-sub> + %sums<doesn't-exist>;
    my $top-types = %types.sort(*.value).tail(5).cache;
    qq:to/EOF/

         OVER-DOCUMENTED:
         ################

         Total over-documented methods:
         ==============================
         total over documented:     $*total
         non-local methods:         {%sums<non-local>.&fmt-with-percent-of('total')}
         non-method routines:       {%sums<non-method-sub>.&fmt-with-percent-of('total')}
         non-existent methods:      {%sums<doesn't-exist>.&fmt-with-percent-of('total')}
        EOF
     ~ (if $top-types.elems ≥ 3 {
              "\n"
            ~ "Types with the most over-documented methods:\n".indent(1)
            ~ "============================================\n".indent(1)
            ~ ($top-types.map({ sprintf(" %-*s %-5d\n",
                                        $top-types.&max-len, .key,
                                        .value)}).join)})
}

multi process($path where {.IO ~~ :d}, %ignored, $exclude --> List) {
    |(lazy $path.dir
               ==> grep({ .basename ~~ none($exclude.split(',')».trim) })
               ==> map({ |process($^next-path, %ignored, $exclude)}))
}

multi process($path, %ignored, $ --> List) {
    # TODO: error if cannot do vvvvv
    my $type-name = (S/.*'doc/Type/'(.*)'.pod6'/$0/).subst(:g, '/', '::') with $path;

    try { ::($type-name).raku;
          ::($type-name).HOW.raku;
          ::($type-name).^methods;
          # if we're at a low enough level that this amount of introspection fails, skip the type
          CATCH { default { return (%( uncheckable => True, :$type-name, path => $path), )}}
    }

    my %uncheckable-method = SetHash.new();
    # Confusingly, many methods returned by ^methods(:local) are *not* local, so we filter by packaged
    my Set $local-methods = (::($type-name).^methods(:local).grep(-> $method {
        # Some builtins don't support the introspection we need, mostly ones that call ForeignCode
        # (which includes NQP methods).  ForeignCode methods typically have the name `<anon>`
        CATCH { default { %uncheckable-method{~$method.name}++ unless $method.name eq '<anon>' } }
        try { $method.package.isa($type-name) } // $method.package ~~ ::($type-name)
    })».name).Set (-) %ignored{$type-name};

    # TODO: add support for %ignored<GLOBAL> ^^^^^

    my ($in-header, $with-signature) = [Z] $path.IO.lines.map({ MethodDoc.parse($_).made}).grep({.elems == 2});

    my %missing-header    = $local-methods (-) $in-header;
    my %missing-signature = $local-methods (-) $with-signature (-) %missing-header;
    ($in-header (-) $local-methods (-) Set.new('', Any)).keys.classify(-> $method {
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
    (%( :$type-name, :$path, :$local-methods, :%uncheckable-method, :%over-documented,
        under-documented => %{:%missing-header, :%missing-signature} ),)
}

sub max-len($pair-list --> Int) { $pair-list.max(*.key.chars).key.chars }

#| Appends an 's' to the provided $noun if the closest preceding number in $phrase is ≥ 2
sub pluralize(Str $phrase, Str $noun --> Str) {
    $phrase ~~ /(\d+) \D* $noun/;
    +$0 == 1 ?? $phrase !! $phrase.subst(/$noun/, $noun ~ 's')
}
