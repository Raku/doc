#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test-Files;

=begin overview

Ensure any text that isn't a code example has valid POD6

=end overview

my $max-jobs = %*ENV<TEST_THREADS> // 2;

my @files = Test-Files.files.grep({$_.ends-with: '.pod6'|'.t'});

plan +@files;

my %data;

sub test-it($job) {
    my $file = $job.command[*-1];
    ok !$job.exitcode && !%data{$file}, "$file has clean POD6"
}

my @jobs;
%data{@files} = 0 xx @files;
for @files -> $file {
    my $p =  Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
    $p.stdout.tap: {;};
    $p.stderr.tap: {
        %*ENV<P6_DOC_TEST_VERBOSE> and diag "$file STDERR: $_";
        %data{$file} = 1;
    }
    push @jobs: $p.start;
    if +@jobs > $max-jobs {
        test-it(await @jobs.shift);
    }
}

for @jobs.map: {await $_} -> $r { test-it($r) }

# vim: expandtab shiftwidth=4 ft=perl6
