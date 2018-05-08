#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Avoid using C<..> - usually a typo for C<.> or C<...>

=end overview

my @files = Test-Files.files.grep({$_.ends-with: '.pod6' or $_.ends-with: '.md'});

plan +@files;
my $max-jobs = %*ENV<TEST_THREADS> // 2;
my %output;

sub test-promise($promise) {
    my $file = $promise.command[*-1];
    test-it(%output{$file}, $file);
}

sub test-it(Str $output, Str $file) {
    my $ok = True;

    for $output.lines -> $line {
        if $line ~~ / <alpha> '..' (<space> | $) / {
            diag "Failure on line `$line`";
            $ok = False;
        }
    }
    my $error = $file;
    ok $ok, "$error: file contains ..";
}

my @jobs;
for @files -> $file {

    my $output = "";

    if $file ~~ / '.pod6' $/ {
        my $a = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
        %output{$file} = "";
        $a.stdout.tap(-> $buf { %output{$file} = %output{$file} ~ $buf });
        push @jobs: $a.start;
        if +@jobs > $max-jobs {
            test-promise(await @jobs.shift)
        }
    } else {
        test-it($file.IO.slurp, $file);
    }
}

for @jobs.map: {await $_} -> $r { test-promise($r) }

# vim: expandtab shiftwidth=4 ft=perl6
