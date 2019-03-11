#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Test-Files;

enum Syntax <CodeDoc TextDoc>;

my $degree = %*ENV<UTIL_THREADS> // 2;

sub check-line(Str $line, Syntax $state) {
    given $line {
        when / ^ '=begin code' / { CodeDoc }
        when / ^ '=for code' /   { CodeDoc }
        when / ^ '=end code' /   { TextDoc }
        when / ^ '=' \w+ /       { TextDoc }
        when / ^ \s ** 4 /       { CodeDoc }
        default                  { $state  }
    }
}

multi sub replace-spaces(Str $file) {
    nextwith $file.IO;
}
multi sub replace-spaces(IO::Path $file) {
    my Syntax $state    = TextDoc;
    my Bool   $modified = False;
    my Bool   $split    = False;
    my Str    @in       = $file.lines;
    my Str    @out      = @in.hyper(:$degree).map(anon sub (Str $in-line) {
        return $in-line unless $in-line;

        $state = check-line $in-line, $state;
        # Perl 5 and Perl 6 should keep regular spaces in code.
        return $in-line if $state == CodeDoc;

        my Str $out-line = $in-line.clone;
        if $split {
            $out-line ~~ s/ ^ \x[0020]? ( 6 | 5 ) /\x[00A0]$0/;
            $split = False;
        } else {
            $out-line ~~ s/ 'Perl' [ \x[0020]+ | \x[00A0] ]? $ /Perl/;
            $split = True if $/;
        }

        $out-line ~~ s:g/ 'Perl' \x[0020] ( 6 | 5 ) /Perl\x[00A0]$0/;
        $modified = True if $out-line ne $in-line;
        $out-line
    });

    if $modified {
        say "Corrected mentions of Perl 5 and 6 to use NBSP in '$file'.";
        $file.spurt(@out.join("\n"), :close);
    }
}

multi sub MAIN() {
    Test-Files.documents.race(:$degree).map(&replace-spaces);
}
multi sub MAIN(Str $file) {
    die "$file does not exist!" unless $file.IO.e;
    die "$file is a directory!" if $file.IO.d;
    replace-spaces $file.IO;
}
