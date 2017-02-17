use v6;
use Test;
use lib 'lib';
use File::Find;

# Extract examples
chdir $?FILE.IO.dirname.IO.dirname;
my $p1 = shell "$*EXECUTABLE-NAME util/extract-examples.p6 --source-path=./doc/ --prefix=./examples/";
chdir 'examples';

my @files;

if @*ARGS {
    # don't pass examples/ as part of the path name
    @files = @*ARGS;
} else {
    @files = find(
        dir => '.',
        type => 'file',
        exclude => /
            | 'Language/5to6-nutshell.p6'
            | 'Language/5to6-perlfunc.p6'
            | 'Language/5to6-perlop.p6'
            | 'Language/5to6-perlsyn.p6'
            | 'Language/5to6-perlvar.p6'
            | 'Language/modules.p6'
            | 'Language/nativecall.p6'
            | 'Language/packages.p6'
            | 'Language/phasers.p6'
            | 'Language/rb-nutshell.p6'
            | 'Language/tables.p6'
            | 'Language/testing.p6'
            | 'Language/traps.p6'
         /,
    );
}

my $proc;
plan +@files;

for @files -> $file {
    $proc = run 'perl6', '-c', $file, out => '/dev/null', err => '/dev/null';
    if $proc.exitcode == 0 {
        pass "$file is compilable";
    } else {
        flunk "$file examples check isn't successful";
    }
}
