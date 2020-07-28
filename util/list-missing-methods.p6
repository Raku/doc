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

#| Scan one or more pod6 files for undocumented methods
sub MAIN(
    IO(Str) $source-path = './doc/Type/',   #= The file or directory to check (default: ./doc/Type)
    Str :$exclude = ".git",                 #= Comma-seperated list of files/directories to ignore (default: .git)
    :$ignore = './util/ignored-methods.txt' #= Path to file with methods to ignore (default ./util/ignored-methods.txt)
) {
    my %total is BagHash; my %missing-methods is BagHash; my %missing-methods-per-type is BagHash;
    for $(process($source-path, EVALFILE($ignore), $exclude)) { my $a = $_;
        when .<uncheckable>.so {
            %total.add('uncheckable') for ^.<uncheckable>;
            say "✗ {.<name>} – documented at  ⟨{.<path>.IO}⟩\n"
            ~ "Skipped as uncheckable\n"; }

        %total.add('errors') for ^+.<errors>;
        %total.add('missing-header') for ^+.<missing-header>;
        %missing-methods-per-type.add($a.<name>) for ^+.<missing-header>;
        for .<missing-header>.keys { %missing-methods.add($_)};
        %total.add('missing-signature') for ^+.<missing-signature>;

        say (+.<errors> || +.<missing-header> || +.<missing-signature> ?? "✗ " !! "✔ ")
        ~ "{.<name>} – documented at ⟨{.<path>.IO}⟩\n"
        ~ ( if +.<errors> {
                  "{+.<errors>} uncheckable method:\n".&pluralize('method').indent(2)
                  ~ .<errors>.join("\n").indent(4) ~ "\n" })
        ~ ( if +.<missing-header> {
                  "{+.<missing-header>} missing method:\n".&pluralize('method').indent(2)
                  ~ .<missing-header>.keys.sort.join("\n").indent(4) ~ "\n" })
        ~ ( if .<missing-signature> {
                  ("{+.<missing-signature>} method without signature:\n"
                      ).&pluralize('method').&pluralize('signature').indent(2)
                  ~ .<missing-signature>.keys.sort.join("\n").indent(4) ~ "\n"});
    };

    say qq:to/EOF/;
         Summary of missing types:
        ===========================
         UNCHECKABLE types:   {%total<uncheckable>}
         UNCHECKABLE methods: {%total<errors>}
         MISSING methods:     {%total<missing-header>}
         SIGNATURE errors:    {%total<missing-signature>}
        EOF

    my $top-missing = %missing-methods.grep(*.value ≥ 10).cache;

    if $top-missing {
       say " Methods missing from 10+ types: \n"
          ~"=================================\n"
          ~ $top-missing.sort(*.value).map({ sprintf(" %-*s    %d\n",
                                                     $top-missing.&max-len, .key,
                                                     .value)}).join
          ~ sprintf("%s\n   %*s  %d\n\n",
                    '-' x ($top-missing.&max-len + 8),
                    $top-missing.&max-len, "TOTAL",
                    $top-missing.map(*.value).sum) };

    my $top-types = %missing-methods-per-type.sort(*.value).tail(10).cache;
    say " Types with the most missing methods: \n"
       ~"======================================\n"
       ~ $top-types.map({ sprintf(" %-*s %-5d\n",
                                  $top-types.max(*.key.chars).key.chars, .key,
                                  .value)}).join;


}


multi process($path where {.IO ~~ :d}, %ignored, $exclude) {
    |(lazy $path.dir
               ==> grep({ .basename ~~ none($exclude.split(',')».trim) })
               ==> map({ process($^next-path, %ignored, $exclude)}))
}

multi process($path, %ignored, $ --> Hash) {
    my $type-name = (S/.*'doc/Type/'(.*)'.pod6'/$0/).subst(:g, '/', '::') with $path;
    when $type-name eq 'independent-routines' | 'Routine::WrapHandle' {
        %( uncheckable => True, name => $type-name, path => $path )#`(TODO) }
    CATCH { default { return %( uncheckable => True, name => $type-name, path => $path ) } }
    my @errors =[];
    my @real-methods = ::($type-name).^methods(:local).grep(-> $method {
        # Some builtins don't support the introspection we need (e.g., NQPRoutine)
        CATCH { default { @errors.push(~$method.name) unless $method.name eq '<anon>' } }
        ($method.package eqv ::($type-name))
    })».name;
    my ($in-header, $with-signature) = [Z] $path.IO.lines.map({ MethodDoc.parse($_).made}).grep({.elems == 2});
    my Set $missing-header      = @real-methods (-) %ignored{$type-name} (-) $in-header;
    my Set $missing-signature   = @real-methods (-) %ignored{$type-name} (-) $with-signature (-) $missing-header;

    %(errors => @errors,
      missing-header => $missing-header,
      missing-signature => $missing-signature,
      path => $path,
      name => $type-name)
}

sub max-len($pair-list --> Int) { $pair-list.max(*.key.chars).key.chars }

#| Appends an 's' to the provided $noun if the closest preceeding number in $phrase is ≥ 2
sub pluralize(Str $phrase, Str $noun --> Str) {
    $phrase ~~ /(\d+) \D* $noun/;
    +$0 == 1 ?? $phrase !! $phrase.subst(/$noun/, $noun ~ 's') }
