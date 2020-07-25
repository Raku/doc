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
    my &process = {
        when .IO ~~ :d {
            for .dir.grep( { .basename ~~ none($exclude.split(',')».trim) }) { process($^next-path) }
        }

        my $type-name = (S/.*'doc/Type/'(.*)'.pod6'/$0/).subst(:g, '/', '::');
        when $type-name eq 'independent-routines' | 'Routine::WrapHandle' { #`(TODO) }
        CATCH { default { say "problematic type «$type-name»" } }
        my @real-methods = ::($type-name).^methods(:local).grep({
            my $name = .name;
            # Log error for builtins like NQPRoutine that don't support the introspection we need.
            CATCH { default { say "problematic method $name in «$type-name»" unless $name eq '<anon>';
                              False }
                  }
            (.package eqv ::($type-name))
        })».name;
        my ($in-header, $with-signature) = [Z] .IO.lines.map({ MethodDoc.parse($_).made}).grep({.elems == 2});
        my Set $missing-header      = @real-methods (-) %ignored{$type-name} (-) $in-header;
        my Set $missing-signature   = @real-methods (-) %ignored{$type-name} (-) $with-signature (-) $missing-header;

        put "{$type-name} – documented at ⟨{.IO}⟩";
        put "{$missing-header.elems} missing methods:";
        put "    {$missing-header.keys.sort.join("\n    ")}\n";
        put "{$missing-signature.elems} missing signatures:";
        put  "    {$missing-signature.keys.sort.join("\n    ")}\n";
    }

    process($source-path)
}
