#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Test-Files;


my $degree = %*ENV<UTIL_THREADS> // 2;


multi sub replace-perl6(Str $file) {
    my $content = my $original-content = slurp $file;
    $content ~~ s:g/ 'Perl' [ \s+ | \x[00A0] ] '6' /Raku/;

    if $content ne $original-content {
        say "Corrected mentions of Perl 6 to Raku in '$file'.";
        $file.IO.spurt($content, :close);
    }
}

multi sub MAIN() {
    Test-Files.documents.race(:$degree).map(&replace-perl6);
}

