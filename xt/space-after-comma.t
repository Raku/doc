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
        next unless $file ~~ / '.' ('pod6') $/;
        next if $file ~~ / 'contributors.pod6' $/; # names are hard.
        push @files, $file;
    }
}

plan +@files;

for @files -> $file {
    my $ok = True;

    my $output = "";

    if $file ~~ / '.pod6' $/ {
        my $a = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
        $a.stdout.tap(-> $buf { $output = $output ~ $buf });
        await $a.start;
    } else {
        $output = $file.IO.slurp;
    }

    for $output.lines -> $line-orig {
        next if $line-orig ~~ / ^ '    '/;
        my $line = $line-orig;

        # ignore these cases already in docs/ that don't strictly follow rule
        $line ~~ s:g/ "','" //;
        $line ~~ s:g/ '","' //;
        $line ~~ s:g/ << 'a,a,a' >> //;
        $line ~~ s:g/ << 'a,a,.' //;
        $line ~~ s:g/ << 'a,a' >> //;
        $line ~~ s:g/ << 'a,' //;
        $line ~~ s:g/ ',a' >> //;
        $line ~~ s:g/ '{AM,PM}' //;
        $line ~~ s:g/ '(SELF,)' //;
        $line ~~ s:g/ '"1,2"' //;
        $line ~~ s:g/ '"a,b"' //;
        $line ~~ s:g/ '($var,)' //;
        $line ~~ s:g/ '(3,)' //;

        if $line ~~ / ',' [ <!before ' '> & <!before $> ] / {
            diag "Failure on line `$line-orig`";
            $ok = False;
        }
    }
    my $error = $file;
    ok $ok, "$error: Must have space after comma.";
}

# vim: expandtab shiftwidth=4 ft=perl6
