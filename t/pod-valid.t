use v6;
use Test;
use lib 'lib';

=begin overview

Insure any text that isn't a code example has a space after each comma.

=end overview

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    for qx<git ls-files>.lines -> $file {
        next unless $file ~~ / '.pod6' $/;
        push @files, $file;
    }
}

plan +@files;

for @files -> $file {

    my $p =  Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
    $p.stdout.tap(-> $buf {});
    $p.stderr.tap(-> $buf {});
    my $r = await $p.start;
    ok !$r.exitcode, "$file has valid POD6"
}

# vim: expandtab shiftwidth=4 ft=perl6
