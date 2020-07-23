#! /usr/bin/env raku
use v6;

sub USAGE () {
print Q:c:to/EOH/;
    Usage: {$*PROGRAM-NAME} [FILE|PATH]

    Scan a single pod6 file or pod6 files under a path for method declarations,
    infer the typename from the filename and output any methods name that is
    found in the type but not in the pod6 file.
EOH
}

class LazyLookup does Associative {
    # Read a file line by line, turn it into a hash in a lazy fashion. Quite
    # handy when only a single file is checked and the key is close to the top
    # of the file.

    has IO::Path $.path;
    has IO::Handle $.in;
    has %!cache;

    submethod BUILD(:$path){ $!path = $path.IO };

    method in {
        $!in //= $!path.open :r or die "could not open ⸨$!path.Str⸩";
        $!in
    }

    method AT-KEY(Str() $key) {
       %!cache{$key} // self!scan-for-key($key)
    }

    method !scan-for-key(Str $key){
        for $.in.lines() {
            # By splitting on # and taking [0], we skip any comment.  If we
            # don't get a typename we either have an empty line or a line
            # starting with a comment.
            my ($type-name, $method-names) = .split('#')[0].split(':')».trim;
            next unless $type-name;
            $method-names.=split(' ').Set;
            %!cache{$type-name} = $method-names;
            return $method-names if $key eq $type-name;
        }
    }
}

grammar MethodDoc {
    token TOP { [<in-header>  | <with-signature>]
                { make [~] ($<in-header><method> // ()), ($<with-signature><method> // ())}}

    token with-signature { <ws> ['multi' <ws>]? <keyword> <ws> <method> '(' }
    token in-header { '=head' \d? <ws> <keyword> <ws> <method> }
    token keyword          { ['method'|'routine'] }
    token method           { <[-'\w]>+ }
}

sub MAIN($source-path = './doc/Type/', Str :$exclude = ".git", :$ignore = 'util/ignored-methods.txt') {
    my \exclude = none('.', '..', $exclude.split(','));

    my \ignore = LazyLookup.new(:path($ignore));

    my \type-pod-files := $source-path.ends-with('.pod6')
    ?? ($source-path.IO,)
    !! gather for $source-path {
        take .IO when .IO.f && .Str.ends-with('.pod6');
        .IO.dir(test => exclude)».&?BLOCK when .IO.d
    }

    # lazy list of (type-name, IO::PATH)
    my \types := gather for type-pod-files».IO {
        my $file-path = S/.*'doc/'['Type'|'Language'](.*)'.pod6'/$0/;
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

    my \matched-methods := gather for methods -> ($type-name, $path, @expected-methods) {
        my ($in-header, $with-signature) = [Z] $path.lines.map({ MethodDoc.parse($_).made });
        my Set $missing-from-header = @expected-methods (-) ignore{$type-name} (-) $in-header;
        take ($type-name, $path, $missing-from-header) if $missing-from-header
    }

    for matched-methods -> ($type-name, $path, Set $missing-from-header) {
        put "Type: {$type-name}, File: ⟨{$path}⟩";
        put $missing-from-header.keys.sort;
        put "";
    };
}


