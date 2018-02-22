#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Test-Files;

=begin overview

Insure any text that isn't a code example has valid POD6

=end overview

my $max-jobs = %*ENV<TEST_THREADS> // 2;

my @files = Test-Files.files.grep({$_.ends-with: '.pod6'});

plan +@files;

my %data;

sub test-it($job) {
    my $file = $job.command[*-1];
    ok !$job.exitcode && !%data{$file}, "$file has clean POD6"
}

my @jobs;
for @files -> $file {
    my $p =  Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
    $p.stdout.tap(-> $buf {});
    $p.stderr.tap(-> $buf { %data{$file} = 1 });
    push @jobs: $p.start;
    if +@jobs > $max-jobs {
        test-it(await @jobs.shift);
    }
}

for @jobs.map: {await $_} -> $r { test-it($r) }

# vim: expandtab shiftwidth=4 ft=perl6
