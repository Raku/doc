#!/usr/bin/env perl6

use v6;

sub MAIN($typename, :$kind='class') {
    my @path-chunks =  $typename.split('::');
    my $filename = @path-chunks.pop ~ '.pod6';
    my $path = 'doc/Type';
    for @path-chunks -> $c {
        $path ~= "/$c";
        unless $path.IO.d {
            mkdir $path.IO.mkdir;
        }
    }

    $path ~= "/$filename";

    spurt $path.IO, Q:q:to/HEADER/;
        =begin pod

        =TITLE $kind $typename

        =SUBTITLE ...

            $kind $typename is SuperClass { ... }

        Synopsis goes here

        HEADER
    spurt $path.IO, Q:c:to/BODY/;

        =head1 Methods

        =head2 method flurb

            method flurb({$typename}:D: *@args --> Str)

        method description here

        =end pod

        # vim: expandtab shiftwidth=4 ft=perl6
        BODY

    say "'$path' written";
    say "(remember to 'git add $path')";
}

# vim: expandtab shiftwidth=4 ft=perl6
