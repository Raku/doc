use v6;
use Test;
use lib 'lib';

=begin overview

Spell check all the pod files in the documentation directory.

Ignore case, and provide a repo-specific list of approved words,
which include technical jargon, method and class names, etc.

=end overview

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    for qx<git ls-files>.lines -> $file {
        next unless $file ~~ /^ 'doc' /;
        next unless $file ~~ / '.pod6' $/;
        next if $file ~~ / 'contributors.pod6' $/; # names are hard.
        push @files, $file;
    }
}

plan +@files;

my $proc = shell('aspell -v');
if $proc.exitcode {
    skip-rest "This test requires aspell";
    exit;
}

for @files -> $file {
    my $pod2text = run('perl6', 'bin/p6doc', $file, :out);

    my $fixer = run('awk', 'BEGIN {print "!"} {print "^" $0}', :in($pod2text.out), :out);

    my $proc = run(<aspell -a --ignore-case --extra-dicts=./xt/words.pws>, :in($fixer.out), :out);

    $proc.out.get; # dump first line.
    my $count;
    for $proc.out.lines -> $line {
        next if $line eq '';
        diag $line;
        $count++;
    }

    my $so-many  = $count // "no";
    ok !$count, "$file has $so-many spelling errors";
}

# vim: expandtab shiftwidth=4 ft=perl6
