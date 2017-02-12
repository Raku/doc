use v6;
use Test;
use lib 'lib';
use File::Find;

# Extract examples
chdir $?FILE.IO.dirname.IO.dirname;
my $p1 = shell "$*EXECUTABLE-NAME util/extract-examples.p6 --source-path=./doc/ --prefix=./examples/";
chdir 'examples';

my @files = find(dir => '.',
                 name => /'Type'|'Language' .*? .p6$/,
                 exclude => /'exceptions.p6'|'ArgFiles.p6'/,
                 type => 'file');
my $proc;
plan +@files;

for @files -> $file {
    $proc = run 'perl6', $file, out => '/dev/null', err => '/dev/null';
    if $proc.exitcode == 0 {
        pass "$file is compileable";
    } else {
        flunk "$file examples check isn't successful";
    }
}
