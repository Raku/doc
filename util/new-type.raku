#!/usr/bin/env raku

# If the documentation for a type does not exist, create the skeleton of the doc
# $ raku util/new-type.raku --kind=role Some::Role
# this creates the file doc/Type/Some/Role.rakudoc

sub MAIN($typename, :$kind='class') {
    my @path-chunks =  $typename.split('::');
    my $filename = @path-chunks.pop ~ '.rakudoc';
    my $path = 'doc/Type';
    for @path-chunks -> $c {
        $path ~= "/$c";
        unless $path.IO.d {
            mkdir $path.IO.mkdir;
        }
    }

    $path ~= "/$filename";
    if $path.IO ~~ :e {
        say "The file $path already exists.";
        exit 1;
    }
    my $fh = open $path, :x;

    spurt $fh, Q:s:to/HEADER/;
        =begin pod

        =TITLE $kind $typename

        =SUBTITLE ...

            $kind $typename is SuperClass { ... }

        Synopsis goes here

        HEADER
    spurt $fh, Q:c:to/BODY/;

        =head1 Methods

        =head2 method flurb

            method flurb({$typename}:D: *@args --> Str)

        method description here

        =end pod

        # vim: expandtab shiftwidth=4 ft=perl6
        BODY
    $fh.close;
    say "'$path' written";
    say "(remember to 'git add $path')";
}
