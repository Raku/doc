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
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(',');
    } else {
        @files = qx<git ls-files>.lines;
    }
}

@files = @files.grep({$_.ends-with('.pod6') or $_.ends-with('.md')})\
               .grep({! $_.ends-with('contributors.pod6')});

plan +@files;
my $max-jobs = %*ENV<TEST_THREADS> // 2;
my %output;

sub test-promise($promise) {
    my $file = $promise.command[*-1];
    test-it(%output{$file}, $file);
}

sub test-it(Str $output, Str $file) {
    my $ok = True;

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
        $line ~~ s:g/ << 'thing,category' >> //;

        if $line ~~ / ',' [ <!before ' '> & <!before $> ] / {
            diag "Failure on line `$line-orig`";
            $ok = False;
        }
    }
    my $error = $file;
    ok $ok, "$error: Must have space after comma.";
}

my @jobs;
for @files -> $file {

    my $output = "";

    if $file ~~ / '.pod6' $/ {
        my $a = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
        %output{$file} = "";
        $a.stdout.tap(-> $buf { %output{$file} = %output{$file} ~ $buf });
        push @jobs: $a.start;
        if +@jobs > $max-jobs {
            test-promise(await @jobs.shift)
        }
    } else {
        test-it($file.IO.slurp, $file);
    }
}

for @jobs.map: {await $_} -> $r { test-promise($r) }

# vim: expandtab shiftwidth=4 ft=perl6
