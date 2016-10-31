use v6;
use Test;
use lib 'lib';

=begin overview

Spell check all the pod files in the documentation directory.

Ignore case, and provide a repo-specific list of approved words,
which include technical jargon, method and class names, etc.

If the test fails, you can make it pass again by changing the
text (fixing the spelling issue), or adding the new word to
xt/words.pws (if it's a word, a class/method name, known
program name, etc.), or to xt/code.pws (if it's a fragment of
text that is part of a code example)

=end overview

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    for qx<git ls-files>.lines -> $file {
        next unless $file ~~ / '.' ('pod6'|'md') $/;
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

# generate a combined words file
my $dict = open "xt/aspell.pws", :w;
$dict.say('personal_ws-1.1 en 0 utf-8');
$dict.say("xt/words.pws".IO.slurp.chomp);
$dict.say("xt/code.pws".IO.slurp.chomp);
$dict.close;

for @files -> $file {
    my $fixer;

    if $file ~~ / '.pod6' $/ {
        my $pod2text = run($*EXECUTABLE-NAME, '--doc', $file, :out);
        $fixer = run('awk', 'BEGIN {print "!"} {print "^" $0}', :in($pod2text.out), :out);
    } else {
        $fixer = run('awk', 'BEGIN {print "!"} {print "^" $0}', $file, :out);
    }

    my $proc = run(<aspell -a --ignore-case --extra-dicts=./xt/aspell.pws>, :in($fixer.out), :out);

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
