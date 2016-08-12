#! /usr/bin/env perl6

use v6;

# - find types under doc/
# - print all local methods for those types
# - list all methods that are not in doc

my method destructure-fmt(Positional:D: $fmt-str, :$separator = " ") {
    sprintf($fmt-str, |self);
}

sub USAGE () {
print Q:c:to/EOH/;
    Usage: {$*PROGRAM-NAME} [FILE|PATH]

    Scan a single pod6 file or pod6 files under a path for method declarations,
    infer the typename from the filename and output any methods name that is
    found in the type but not in the pod6 file.
EOH
}

sub MAIN($source-path = './doc/Type/', Str :$exclude = ".git") {
    my \exclude = none('.', '..', $exclude.split(','));

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
        take ($type-name, $path, ::($type-name).^methods(:local).grep({
            my $name = .name;
            CATCH { default { say "problematic method $name in $type-name" unless $name eq '<anon>'; False } }
            (.package ~~ ::($type-name))
        })».name) 
    }

    my \matched-methods := gather for methods -> ($type-name, $path, @expected-methods) {
        my @found-methods = ($path.slurp ~~ m:g/'Defined as:' \s+ method \s (<[-'\w]>+)/)».[0];
        my @missing-methods = @expected-methods (-) @found-methods;
        take ($type-name, $path, @missing-methods)
    }

    .&destructure-fmt("Type: %s, File: ⟨%s⟩\n%s\n").say for matched-methods;
}

