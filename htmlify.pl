#!/usr/bin/env perl6
use v6;

# this script isn't in bin/ because it's not meant
# to be installed.

sub MAIN($out_dir = 'html') {
    mkdir $out_dir unless $out_dir.IO ~~ :e;

    # TODO:  be recursive instead
    my @source = dir('lib').grep(*.f).grep(rx{\.pod$});

    for (@source) {
        my $podname = .basename.subst(rx{\.pod$}, '').subst(:g, '/', '::');
        say "$_.path() => $podname";
        shell("perl6 --doc=HTML $_.path() > $out_dir/$podname.html");
    }
}
