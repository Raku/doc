#! /usr/bin/env perl6

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

sub MAIN($source-path = './doc/Type/', Str :$exclude = ".git", :$ignore = 'util/ignored-methods.txt') {
    my \exclude = none('.', '..', $exclude.split(','));

    my \ignore = LazyLookup.new(:path($ignore));

    my \type-pod-files := $source-path.ends-with('.pod6')
    ?? ($source-path.IO,)
    !! gather for $source-path {
        take .IO when .IO.f && .Str.ends-with('.pod6');
        .IO.dir(test => exclude)».&?BLOCK when .IO.d
    }

    my $prefix-length = $source-path.ends-with('.pod6') ?? ($source-path.chars - $source-path.IO.basename.chars) !! $source-path.chars;

    # lazy list of (type-name, IO::PATH)
    my \types := gather for type-pod-files».IO {
        my $file-path = .substr($prefix-length);
        my $type-name = $file-path.chop(5).subst(:g, '/', '::');

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
        my @found-methods = ($path.slurp ~~ m:g/method \s (<[-'\w]>+) '('/)».[0];
        my Set $missing-methods = @expected-methods (-) ignore{$type-name} (-) @found-methods».Str;
        # dd @missing-methods, @expected-methods, @found-methods».Str;
        take ($type-name, $path, $missing-methods) if $missing-methods
    }

    for matched-methods -> ($type-name, $path, Set $missing-methods) {
        put "Type: {$type-name}, File: ⟨{$path}⟩";
        put $missing-methods;
        put "";
    };
}
