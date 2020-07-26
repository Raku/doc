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
    Str :$exclude = ".git",                 #= Comma-seperated list of file extensions to ignore (default: .git)
    :$ignore = './util/ignored-methods.txt' #= File listing methods to ignore (default ./util/ignored-methods.txt)
) {
    my %ignored is Map = EVALFILE($ignore);
    sub process($path)  {
        when $path.IO ~~ :d {
            flat (lazy $path.dir.grep({ .basename ~~ none($exclude.split(',')».trim) }).map({ process($^next-path)}));
        }

        my $type-name = (S/.*'doc/Type/'(.*)'.pod6'/$0/).subst(:g, '/', '::') with $path;
        when $type-name eq 'independent-routines' | 'Routine::WrapHandle' { #`(TODO) }
        CATCH { default { return "✗ $type-name – documented at  ⟨{$path.IO}⟩\nSkipped as uncheckable\n" } }
        my @errors =[];
        my @real-methods = ::($type-name).^methods(:local).grep({
            my $name = .name;
            # Some builtins don't support the introspection we need (e.g., NQPRoutine)
            CATCH { default { @errors.push("$name") unless $name eq '<anon>';
                              False } }
            (.package eqv ::($type-name))
        })».name;
        my ($in-header, $with-signature) = [Z] $path.IO.lines.map({ MethodDoc.parse($_).made}).grep({.elems == 2});
        my Set $missing-header      = @real-methods (-) %ignored{$type-name} (-) $in-header;
        my Set $missing-signature   = @real-methods (-) %ignored{$type-name} (-) $with-signature (-) $missing-header;

        (+@errors || +$missing-header || +$missing-signature ?? "✗ " !! "✔ ")
        ~ "{$type-name} – documented at ⟨{$path.IO}⟩\n"
        ~ ( if +@errors {
            "  {+@errors} methods couldn't be checked:\n    {@errors.join("\n    ")}\n" })
        ~ ( if +$missing-header {
            "  {+$missing-header} methods were missing:\n    {$missing-header.keys.sort.join("\n    ")}\n"})
        ~ ( if $missing-signature {
            "  {+$missing-signature} methods lacked signatures:\n    {$missing-signature.keys.sort.join("\n    ")}\n"})
    }

    for process($source-path) { .say };
}
