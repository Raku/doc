#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test-Files;

=begin overview

Ensure any test file, including author tests, have clean syntax and POD

=end overview

my $max-jobs = %*ENV<TEST_THREADS> // 2;

my @files-t = Test-Files.files.grep({$_.ends-with: '.t'});
if @files-t {
    plan +@files-t;
} else {
    plan :skip-all<No test files specified>
}

my %data;
test-files( @files-t );

sub test-it($job) {
    my $file = $job.command[*-1];
    ok !$job.exitcode && !%data{$file}, "$file POD6 and syntax check out"
}

sub test-files( @files ) {
    my @jobs;
    %data{@files} = 0 xx @files;
    for @files -> $file {
        my $p =  Proc::Async.new($*EXECUTABLE-NAME, '--c', $file);
        $p.stdout.tap: {;};
        $p.stderr.tap: {
            %*ENV<P6_DOC_TEST_VERBOSE>
            and diag qq:to/EOF/;
There's been this error in file: $file
$_
EOF
            %data{$file} = 1;
        }
        push @jobs: $p.start;
        if +@jobs > $max-jobs {
            test-it(await @jobs.shift);
        }
    }

    # In case there's something left to run.
    for @jobs.map: {await $_} -> $r { test-it($r) }
}


# vim: expandtab shiftwidth=4 ft=perl6
