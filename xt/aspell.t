use v6;
use Test;
use lib 'lib';

my @files;

for qx<git ls-files>.lines -> $file {
    next unless $file ~~ / '.pod6' $/;
    next if $file ~~ / 'contributors.pod6' $/; # names are hard.
    push @files, $file;
}

plan +@files;

my $file-count = 1;
for @files -> $file {
    $file-count++;
    #last if $file-count > 15;
  
    my $fixer = run('awk', 'BEGIN {print "!"} {print "^" $0}', $file, :out);

    my $proc = run(<aspell -a --ignore-case --extra-dicts=./xt/.aspell.pws>, :in($fixer.out), :out);

    $proc.out.get; # dump first line.
    my $count; 
    for $proc.out.lines -> $line {
        next if $line eq '';
        diag $line;
        $count++;
    }
  
    my $so-many  = $count ?? $count !! "no";
    ok !$count, "$file has $so-many spelling errors";
}

# vim: expandtab shiftwidth=4 ft=perl6
