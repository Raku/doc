use v6;
use Test;
use lib 'lib';

=begin overview

Insure any text that isn't a code example has valid POD6

=end overview

my @files;
my $max-jobs = %*ENV<TEST_THREADS> // 2;

if @*ARGS {
    @files = @*ARGS;
} else {
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(',').grep(*.IO.e);
    } else {
        @files = qx<git ls-files>.lines;
    }
}
@files = @files.grep(/'.pod6'$/);

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
