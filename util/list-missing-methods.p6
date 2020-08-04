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

enum Summary <yes no only>;
#| Scan a pod6 file or directory of pod6 files for over- and under-documented methods
sub MAIN(
    IO(Str) $src = './doc/Type/',               #= Path to the file or directory to check
    Str :e(:$exclude)= ".git",                  #= Comma-separated list of files/directories to ignore
    Str :d(:$display) = 'all',                  #= Comma-separated list of documentation types to display
    Summary :s(:$summary) = yes,                #= Whether to display summary statistics
    :i(:$ignore) = './util/ignored-methods.txt' #= Path to file with methods to skip
) {
    # TODO: Comment
    my %summary = %{
        totals => %{ :0checked-types, :0unchecked-types, :0checked-methods, :0unchecked-methods },
        under-documented => %{ sums => BagHash.new(), types => BagHash.new(), methods => BagHash.new() },
        over-documented  => %{ sums => BagHash.new(), types => BagHash.new() },
    }

    my $output = $(process($src, EVALFILE($ignore), $exclude)).map( {
        when .<uncheckable>.so {
            %summary<totals><unchecked-types>++;
            "✗ {.<type-name>} – documented at  ⟨{.<path>.IO}⟩\nSkipped as uncheckable\n";
        }
        %summary<totals><checked-types>++;
        %summary<totals><checked-methods> += .<local-methods>.elems;
        %summary<totals><unchecked-methods> += .<uncheckable-method>.elems;
        %summary<under-documented><sums>{.key} += .value.elems for .<under-documented>.pairs;
        %summary<over-documented><sums>{.key}  += .value.elems for .<over-documented>.pairs ;
        %summary<under-documented><methods>.add($_)            for .<under-documented><missing-header>.keys;
        %summary<under-documented><types>{.<type-name>} += .<under-documented><missing-header>.elems;
        %summary<over-documented><types>{.<type-name>}  += .<over-documented><doesn't-exist>.elems;

        (.<uncheckable-method> ∪  |.<under-documented>.values ∪ |.<over-documented>.values ?? "✗ " !! "✔ ")
         ~ "{.<type-name>} – documented at ⟨{.<path>.IO}⟩\n"
         ~ fmt-uncheckable-methods(.<uncheckable>)
         ~ (if $display ~~ ('under' | 'all') { fmt-under-documented-methods(.<under-documented>) } )
         ~ fmt-over-documented-methods(.<over-documented>)
    });
    for $output[] {
        if $summary ~~ (yes | no) { .say }
    }

    if $summary ~~ (yes | only) {
        say fmt-totals-summary(|%summary<totals>);
        say fmt-under-documented-summary(|%summary<under-documented>);
        say fmt-over-documented-summary(|%summary<over-documented>);
    }
}

sub USAGE() {
    my &fmt-param = { $^a ~ (' ' x (20 - $^a.chars) ~ $^b.WHY ~ (with $^b.default { " [default: {.()}]"})) }
    say qq:to/EOF/
      Usage: $*PROGRAM-NAME [OPTION]... [SRC]
      {&MAIN.WHY}

      ARGS:
        { &MAIN.signature.params.grep(!*.named).map({ fmt-param(.name.substr(1).uc, $_) }).join("\n")}

      OPTIONS:
        { &MAIN.signature.params.grep(*.named).map({
              fmt-param(.named_names.reverse.map({'-' x ++$ ~ $_}).join(', '), $_);
          }).join("\n  ")}

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
         ("{+.<non-local>} non-local method with documentation:\n"
             ).&pluralize('method').indent(2)
         ~ .<non-local>.sort.join("\n").indent(4) ~ "\n"});
}

sub fmt-totals-summary(:$checked-types, :$unchecked-types, :$checked-methods, :$unchecked-methods --> Str) {
    qq:to/EOF/
         ##################
         #    SUMMARY     #
         ##################

         Total types/methods processed:
         ==============================
         types checked:   $checked-types
         types skipped:   $unchecked-types
         methods checked: $checked-methods
         methods skipped: $unchecked-methods
        EOF
}

sub fmt-under-documented-summary(:%sums, :%methods, :%types) {
    my $top-missing = %methods.grep(*.value ≥ 20).cache;
    my $top-types = %types.sort(*.value).tail(5).cache;
    qq:to/EOF/
         UNDER-DOCUMENTED:
         #################

         Total (potentially) missing documentation:
         ==========================================
         missing methods:           {%sums<missing-header>}
         methods with no signature: {%sums<missing-signature>}

         {if $top-missing {
                   "Methods missing from 20+ types:\n"
                 ~ " ===============================\n"
                 ~ $top-missing.sort(*.value).map({ sprintf(" %-*s    %d",
                                                            $top-missing.&max-len, .key,
                                                            .value)}).join("\n")
                 ~ sprintf("\n %s\n   %*s  %d\n",
                           '-' x ($top-missing.&max-len + 7),
                           $top-missing.&max-len, "TOTAL",
                           $top-missing.map(*.value).sum) }}
         Types with the most missing methods:
         ====================================
        {$top-types.map({ sprintf(" %-*s %-5d",
                                  $top-types.&max-len, .key,
                                  .value)}).join("\n")}
        EOF
}

sub fmt-over-documented-summary(:%sums, :%types) {
    my $top-types = %types.sort(*.value).tail(5).cache;
    qq:to/EOF/
         OVER-DOCUMENTED:
         ################

         Total over-documented methods:
         ==============================
         non-local methods:         {%sums<non-local>}
         non-method routines:       {%sums<non-method-sub>}
         non-existent methods:      {%sums<doesn't-exist>}

         Types with the most over-documented methods:
         ============================================
        {$top-types.map({ sprintf(" %-*s %-5d\n",
                                   $top-types.&max-len, .key,
                                   .value)}).join}
        EOF
}


multi process($path where {.IO ~~ :d}, %ignored, $exclude) {
    |(lazy $path.dir
               ==> grep({ .basename ~~ none($exclude.split(',')».trim) })
               ==> map({ process($^next-path, %ignored, $exclude)}))
}

multi process($path, %ignored, $ --> Hash) {
    my $type-name = (S/.*'doc/Type/'(.*)'.pod6'/$0/).subst(:g, '/', '::') with $path;

    try { ::($type-name).raku;
          ::($type-name).HOW.raku;
          ::($type-name).^methods;
          # if we're at a low enough level that this amount of introspection fails, skip the type
          CATCH { default { return %( uncheckable => True, :$type-name, path => $path)}}
    }

    my %uncheckable-method = SetHash.new();
    # Confusingly, many methods returned by ^methods(:local) are *not* local, so we filter by packaged
    my Set $local-methods = (::($type-name).^methods(:local).grep(-> $method {
        # Some builtins don't support the introspection we need, mostly ones that call ForeignCode
        # (which includes NQP methods).  ForeignCode methods typically have the name `<anon>`
        CATCH { default { %uncheckable-method{~$method.name}++ unless $method.name eq '<anon>' } }
        try { $method.package.isa($type-name) } // $method.package ~~ ::($type-name)
    })».name).Set (-) %ignored{$type-name};

    my ($in-header, $with-signature) = [Z] $path.IO.lines.map({ MethodDoc.parse($_).made}).grep({.elems == 2});

    my %missing-header    = $local-methods (-) $in-header;
    my %missing-signature = $local-methods (-) $with-signature (-) %missing-header;
    my %over-documented  = ($in-header (-) $local-methods (-) Set.new('', Any)).keys.classify(-> $method {
        # if ^find_method finds it, it's *somewhere* in the inheritance graph, just not local
        when try {::($type-name).^find_method($method).defined} { 'non-local' }
        # If the type matches first item in the signiture, then it's a sub the type can call with .&…
        when try { any(&::($method).candidates.map(-> $a {::($type-name) ~~ $a.signature.params.head.type}))} {
             'non-method-sub'
         }
        "doesn't-exist"
    });
    %( :$type-name, :$path, :$local-methods, :%uncheckable-method, :%over-documented,
       under-documented => %{:%missing-header, :%missing-signature} )
}

sub max-len($pair-list --> Int) { $pair-list.max(*.key.chars).key.chars }

#| Appends an 's' to the provided $noun if the closest preceding number in $phrase is ≥ 2
sub pluralize(Str $phrase, Str $noun --> Str) {
    $phrase ~~ /(\d+) \D* $noun/;
    +$0 == 1 ?? $phrase !! $phrase.subst(/$noun/, $noun ~ 's')
}
