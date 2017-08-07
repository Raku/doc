use v6;
use Test;
use lib 'lib';

=begin overview

Insure any text that isn't a code example has a space after each comma.

=end overview

my @files;
my $max-jobs = %*ENV<TEST_THREADS> // 2;

if @*ARGS {
    @files = @*ARGS;
} else {
    for qx<git ls-files>.lines -> $file {
        next unless $file ~~ / '.pod6' $/;
        push @files, $file;
    }
}

plan +@files;

sub test-it($job) {
    ok !$job.exitcode, "{$job.command[*-1]} has valid Pod6"
}

my @jobs;
for @files -> $file {
    my $p =  Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
    $p.stdout.tap(-> $buf {});
    $p.stderr.tap(-> $buf {});
    push @jobs: $p.start;
    if +@jobs > $max-jobs {
        test-it(await @jobs.shift);
    }
}

for @jobs.map: {await $_} -> $r { test-it($r) }

# vim: expandtab shiftwidth=4 ft=perl6
