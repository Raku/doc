use v6;
use Test;
use lib 'lib';

=begin overview

Check for duplicate words in documentation.

Ignore case, ignore implicit code, and explicit C<=begin code> blocks.

Unless we're on a line with a pod marker, save the last word and compare it to
the next line as well.

Allow a few well known duplicates, like 'long long'

=end overview

my @files;
my $safe-dups = Set.new(<method long>); # Allow these dupes

if @*ARGS {
    @files = @*ARGS;
} else {
    if %*ENV<TEST_FILES> {
        @files = %*ENV<TEST_FILES>.split(',').grep(*.IO.e);
    } else {
        @files = qx<git ls-files>.lines;
    }
}
@files = @files.grep({$_.ends-with('.pod6') or $_.ends-with('.md')});

plan +@files;

enum file-type <pod6 plain>;

for @files -> $file {
    my $type = $file ~~ / '.pod6' $/ ?? pod6 !! plain;

    my @dupes;
    my $line-num = 0;
    my $last-word = ""; # Keep track of the last word on a line (unless it's a pod directive)
    my $in-code = False;
    for $file.IO.lines -> $line is copy {
        $line-num++;
        next if $type == pod6 && $line ~~ /^ '  ' /;
        my $is-pod = $line ~~ /^ '=' /;
        if !$in-code && $line ~~ /^ '=begin code' / {
            $in-code = True;
        } elsif $in-code && $line ~~ /^ '=end code' / {
            $in-code = False;
        }

        $line = $last-word ~ " " ~ $line;
        $last-word = "";

        next if $in-code;

        my @line-dupes = ($line ~~ m:g/:i << (<alpha>+) >> \s+ << $0 >> /).map(~*[0]);
        for @line-dupes -> $dupe {
            next if $safe-dups ∋ ~$dupe[0];
            @dupes.push: "“" ~ $dupe[0] ~ "” on line $line-num";
        }

        next if $is-pod;
        $line ~~ m/ << (<alpha>+) \s* $/;
        if ?$/ {
            $last-word = ~$0;
        }
    }

    my $message = "$file has duplicate words";
    if @dupes {
        is @dupes.join("\n"), '', $message;
    } else {
        pass $message;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
