#! /usr/bin/env raku
use v6;

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
    my \exclude = none('.', '..', $exclude.split(','));

    my \type-pod-files := $source-path.ends-with('.pod6')
    ?? ($source-path.IO,)
    !! gather for $source-path {
        take .IO when .IO.f && .Str.ends-with('.pod6');
        .IO.dir(test => exclude)».&?BLOCK when .IO.d
    }

    # lazy list of (type-name, IO::PATH)
    my \types := gather for type-pod-files».IO {
        my $file-path = S/.*'doc/Type/'(.*)'.pod6'/$0/;
        my $type-name = $file-path.subst(:g, '/', '::');
        take ($type-name, .IO)
    }

    my \methods := gather for types -> ($type-name, $path) {
        CATCH { default { say "problematic type «$type-name»" } }
        take ($type-name, $path, ::($type-name).^methods(:local).grep({
            my $name = .name;
            # Some builtins like NQPRoutine don't support the introspection we need.
            # We solve this the British way, complain and carry on.
            CATCH { default { say "problematic method $name in «$type-name»" unless $name eq '<anon>'; False } }
            (.package ~~ ::($type-name))
        })».name)
    }

    my %ignored is Map = EVALFILE($ignore);
    my \matched-methods := gather for methods -> ($type-name, $path, @existing) {
        my ($in-header, $with-signature) = [Z] $path.lines.map({ MethodDoc.parse($_).made}).grep({.elems == 2});
        my Set $missing-header      = @existing (-) %ignored{$type-name} (-) $in-header;
        my Set $missing-signature   = @existing (-) %ignored{$type-name} (-) $with-signature (-) $missing-header;
        if $missing-header || $missing-signature {
            take ($type-name, $path, $missing-header, $missing-signature) }
    }

    for matched-methods -> ($type-name, $path, Set $missing-from-header, Set $missing-signature) {
        put "{$type-name} – documented at ⟨{$path}⟩";
        put "{$missing-from-header.elems} missing methods:";
        put "    {$missing-from-header.keys.sort.join("\n    ")}\n";
        put "{$missing-signature.elems} missing signatures:";
        put  "    {$missing-signature.keys.sort.join("\n    ")}\n";
    };
}
