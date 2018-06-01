#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test-Files;

my $degree = %*ENV<TEST_THREADS> // 2;
my @files = Test-Files.documents;

enum Syntax (
    CodeDoc => 0,
    TextDoc => 1
);

sub check-line($line, $state) {
    given $line {
        when /^\=begin\scode/ { CodeDoc }
        when /^\=for\scode/   { CodeDoc }
        when /^\=end\scode/   { TextDoc }
        when /^\=\w+/         { TextDoc }
        when /^\s ** 4/       { CodeDoc }
        default               { $state  }
    }
}

my @promises = @files.map(-> $file {
    Promise.start({
        my Str    @in       = $file.IO.lines;
        my Str    @out      = [];
        my Syntax $state    = TextDoc;
        my Bool   $modified = False;
        my Bool   $split    = False;
        for @in -> $in-line {
            unless $in-line {
                @out.push($in-line);
                next;
            }

            $state = check-line($in-line, $state);
            if $state ~~ CodeDoc {
                # Perl 5 and Perl 6 should keep regular spaces in code.
                @out.push($in-line);
                next;
            }

            my $out-line = $in-line;
            if $split {
                $out-line = $in-line.subst(/^\s?<?before 5||6>/, "\x00A0");
                $split = False;
            } else {
                $out-line = $in-line;
                $split = True if $out-line.ends-with('Perl');
            }

            $out-line ~~ s:g/Perl\x[0020](5||6)/Perl\x[00A0]$0/;
            $modified = True if $out-line ne $in-line;
            @out.push($out-line);
        }

        if $modified {
            say "Corrected mentions of Perl 6 to use NBSP in '$file'.";
            $file.IO.spurt(@out.join("\n"), :close);
            $modified = False;
        }
    })
});

@promises.race(:$degree);
