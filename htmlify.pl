#!/usr/bin/env perl6
use v6;

# this script isn't in bin/ because it's not meant
# to be installed.

my %routines;

sub MAIN($out_dir = 'html') {
    mkdir $out_dir unless $out_dir.IO ~~ :e;

    # TODO:  be recursive instead
    my @source = dir('lib').grep(*.f).grep(rx{\.pod$});

    my $tempfile = join '-', "tempfile", $*PID, (1..1000).pick ~ '.temp';

    for (@source) {
        my $podname = .basename.subst(rx{\.pod$}, '').subst(:g, '/', '::');
        say "$_.path() => $podname";
        shell("perl6 --doc=HTML $_.path() > $out_dir/$podname.html");

        # disable the rest of the processing for now, doesn't 
        # really do anthing except burning CPU cycles
        next;

        shell("perl6 -Ilib --doc=Serialization $_.path() > $tempfile");
        # assume just one pod block for now
        my ($pod) = eval slurp $tempfile;
        my @chunks = chunks-grep($pod.content,
                :from({ $_ ~~ Pod::Heading and .level == 2}),
                :to({ $^b ~~ Pod::Heading and $^b.level <= $^a.level}),
            );
        for @chunks {
            say .perl;
        }
        unlink $tempfile;
    }
}

sub chunks-grep(:$from!, :&to!, *@elems) {
    my @current;

    gather {
        for @elems -> $c {
            if @current && ($c ~~ $from || to(@current[0], $c)) {
                take [@current];
                @current = ();
            }
            elsif @current or $c ~~ $from {
                @current.push: $c;
            }
        }
        take [@current] if @current;
    }
}
