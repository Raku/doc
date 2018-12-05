#!/usr/bin/env perl6

# NOTE: This file is called by the Makefile (or Sakefile) from the
#       top level of the doc repo and all files are referenced
#       relative to it.

=begin overview

Manage page order in the generated documents,
so that documents appear just the way we want them. Uses source files
and POD metadata to generate new files,
which are the ones actually used as source for the stuff.

=end overview

# pod6 source directory of interest for auto-gen handling:
my $lang-dir = 'doc/Language';
# pod6 source d#irectory
my $fromdir = $lang-dir;
my $cfil    = '00-POD6-CONTROL'; # base filename
my $cloc    = "$lang-dir/$cfil";

# location for placing the generated files
# htmlify.p6 AND pod2bigpage (see Makefile) must use this location for building:
my $build-dir = 'build';
my $tgt-dir   = 'Language';
my $todir     = "$build-dir/$tgt-dir";

constant $TITLE    = '=TITLE';
constant $SUBTITLE = '=SUBTITLE';
constant $NBSPACE  = "\x[A0]";

my $usage = "Usage: $*PROGRAM-NAME update [--manage ] | control [--debug --help]";
sub USAGE { say $usage }
my %*SUB-MAIN-OPTS = named-anywhere => 1;
unit sub MAIN(
    $mode = '',
    Bool :d(:$debug)   = False,
    Bool :h(:$help)    = False,
    Bool :m(:$manage) = False,
    # special options for control:
    Bool :r(:$refresh) = False,
    Bool :n(:$new)     = False,
);

help() if $help;

given $mode {
    when /^c/ {
        EXIT("No 'refresh' or 'new' option supplied.")
            if !($new || $refresh);
        do-control();
    }
    when /^u/ {
        EXIT("Options 'refresh' and 'new' are not used with 'update'.")
            if ($new || $refresh);
        if $manage {
            do-update()
        } else {
            copy-dir-tree :fromdir('doc'), :todir('build')
        }
    }
    default {
        EXIT("\$mode '$mode' is unknown");
    }
}

sub do-update () {
    say "DEBUG: in sub {&?ROUTINE.name}" if $debug eq 'r';

    # FIRST
    # write the auto-generated pod6 files used for the Language page

    # visit later
    write-Language-files();

    # THEN
    # copy all under the doc dir to the build dir
    # NOTE this assumes the sort order is alpha by file name
    # NOTE we exclude the Language dir
    # visit later
    copy-dir-tree(:fromdir('doc'), :todir('build'), :exclude('Language'));
    #copy-dir-tree :fromdir('doc'), :todir('build');
}

sub copy-dir-tree(:$fromdir, :$todir, :$exclude = '' ) {
    # recursively copy tree to another tree
    return if !$fromdir.IO.d;

    say "DEBUG: \$fromdir: '$fromdir', \$exclude: '$exclude'" if $debug;
    # skip some dirs, e.g., Language
    return if $exclude && $fromdir ~~ /$exclude/;

    # create the target dir if need be
    mkdir $todir if !$todir.IO.d;
    # need a file to save the dir for git
    my $tf = "$todir/000-README";
    if !$tf.IO.f {
        spurt $tf, 'This file is required to save the directory under git.';
    }

    # copy all files first, then recurse into directories we find
    say "DEBUG: copy trees from '$fromdir' to '$todir'" if $debug;
    my @sdirs;
    for (dir $fromdir) -> $f {
        my $fb = $f.IO.basename;
        if $f.IO.d {
            say "  DEBUG: pushing dir '$fb' for later handling'" if $debug;
            push @sdirs, $fb;
            next;
        }
        # must be a file
        next if $f !~~ /'.pod6'$/;
        say "  DEBUG: copying file '$f' to dir '$todir'" if $debug;
        # for current rakudo we must copy to a file, not its dir
        copy $f, "$todir/$fb";
    }
    for @sdirs -> $d {
        say "    DEBUG: handling pushed dir '$d'..." if $debug;
        say "       copying from dir '$fromdir/$d' to '$todir/$d..." if $debug;
        copy-dir-tree :fromdir("$fromdir/$d"), :todir("$todir/$d"), :$exclude;
    }
}

sub write-Language-files() {
    # the $todir must exist or be created
    mkdir $todir if !$todir.IO.d;

    my %data; # note data do NOT have page order, that is determined from the control file
    get-pod6-src-data(:$fromdir, :%data);

    # read the control file and generate the pod6 files accordingly
    die "FATAL: Control file '$cloc' not found." if !$cloc.IO.f;

    # need some indices
    my @a = 'A' .. 'Z';     # for the group pages
    my @n = '001' .. '999'; # page order for all files

    my %actually-generated;
    for $cloc.IO.lines -> $line is copy {
        $line = strip-comment $line;
        say "DEBUG cloc line: '$line'" if $debug;
        next if $line !~~ /\S/;

        # line may be a group line or a pod6 data line
        if $line ~~ /:i ^ \h* 'section:' (.*) / {
            # a new group
            my $group-char = shift @a;

            # straight numerical order for all pages, including group separator pages
            my $page-order = shift @n;

            my $title = ~$0.words.join(' ');
            # the group page is written to the todir
            write-group-page $group-char, $title, $page-order;
        }
        else {
            # a child of the current group
            # title... FILE: stripped-filename
            my $FILE = 'FILE:';
            my $idx = rindex $line, $FILE;
            # skip lines with missing filename
            next if !$idx.defined;

            my $n = $FILE.chars;
            my $key-fname = substr $line, $idx+$n;
            $key-fname .= trim;
            my $fname = $key-fname ~ '.pod6';
            %actually-generated{$key-fname} = True;

            # source filename
            my $from = "$fromdir/$fname";

            say "DEBUG: from '$from'" if $debug;

            # straight numerical order for all pages, including group separator pages
            my $page-order = shift @n;

            # target filename
            # NOTE the target filename must have the page-order as prefix to its filename
            my $to = "$todir/{$page-order}-{$fname}";
            say "DEBUG: to '$to'" if $debug;
            my $fh = open $to, :w;
            my $line-no = 1;
            for $from.IO.lines -> $line is copy {
                if $line ~~ /^ \h* '=begin' \h* pod / {
                    # check any existing :page-order entry
                    if $line ~~ / ':page-order<' (.*) '>' / {
                        EXIT(":page-order entry not allowed in source files ('$from')");
                    }
                    else {
                        #$fh.say: "$line :page-order<{$page-order}>";
                        if $line-no < 5 {
                            $fh.say: "# THIS FILE IS AUTO-GENERATED--ALL EDITS WILL BE LOST";
                            $fh.say: $line ~ " :link<$key-fname>";
                            #$fh.say: "=comment THIS FILE IS AUTO-GENERATED--ALL EDITS WILL BE LOST";
                        } else {
                            $fh.say: $line;
                        }
                    }
                    next;
                }
                $line-no++;
                $fh.say: $line;
            }
            $fh.close;
        }
    }
    my $not-generated = %data.keys (-) %actually-generated.keys;
    say "These files → $not-generated\nhave not been generated" if $not-generated;

    say "Normal end.";
    say "See new target files in dir '$todir'";
}

sub do-control() {
    # write or refresh the Language control file
    # TODO make more general for multiple dirs

    my %data;
    get-pod6-src-data(:$fromdir, :%data);
    #dd %data;
    say %data.gist if $debug;
    #die "debug exit";

    if $refresh {
        refresh-control-file %data;
    }
    elsif $new {
        write-orig-control-file %data;
    }
}

sub refresh-control-file(%data) {
    # TODO finish this sub
    # read the current file, update the title
}

sub write-orig-control-file(%data) {
    say "DEBUG: in sub {&?ROUTINE.name}" if $debug;
    # do not overwrite an existing control file
    if $cloc.IO.f {
        print qq:to/HERE/;
        WARNING: Control file '$cloc' exists.
                 Do you want to overwrite it
        HERE
        my $ans = prompt "         after a copy is made? (y/n) ";
        if $ans ~~ /:i ^y/ {
            # make a copy
            my $bak = $cloc ~ '.bak';
            copy $cloc, $bak;
        }
        else {
            EXIT("Aborting and not overwriting.");
        }
    }

    # sort the pod6 source files by established page order
    # first, then alpha for those without a page
    # order value
    my %p; # page sort
    my %a; # alpha sort
    for %data.keys -> $f {
        my $p = %data{$f}<page-order>;
        my $t = %data{$f}<title>;
        if $p {
            # dup key is an error
            die "FATAL: page-order key '$p' is a duplicate"
                if %p{$p};
            %p{$p}<file>  = $f;
            %p{$p}<title> = $t;
        }
        else {
            %a{$f} = $t;
        }
    }

    # ready to write the control file
    my $fh = open $cloc, :w;
    $fh.say: qq:to/HERE/;
        # Do not edit this file except to sort the lines in the
        # desired order.
        #
        # DO NOT REMOVE OR MODIFY THE FILE NAME AT THE END OF EACH LINE
        HERE

    for %p.keys.sort ->$o {
        #say "debug p key: $o" if $debug;
        my $fname = %p{$o}<file>;
        my $title = %p{$o}<title>;
        say "$title FILE: $fname" if $debug;
        $fh.say: "$title FILE: $fname";
    }
    for %a.keys.sort -> $f {
        #say "debug a key: $f";
        my $title = %a{$f}<title>;
        say "$title FILE: $f" if $debug;
        $fh.say: "$title FILE: $f";
    }
    $fh.close;

    say "Normal end.";
    say "See new file '$cloc'";
}

sub strip-pod6-filename($fname is copy) {
    $fname .= basename;
    $fname ~~ s/'.pod6'$//;
    return $fname;
}

sub get-pod6-src-data(:fromdir($fdir), :%data) {
    # caller: do-control
    # data are used to generate a new control file
    #   AND the auto-generated target files
    die "FATAL: no such directory '$fdir'" if !$fdir.IO.d;

    # hash key: stripped-filename
    #   subkey: title
    #   subkey: subtitle [NOT used by the control file]

    my $n = 0;
    for (dir $fdir) -> $f {
        next if $f !~~ /'.pod6'$/;
        next if !$f.IO.f;
        ++$n;
        last if $debug && $n > 2;

        say "working file '$f'" if $debug;
        # we use the name for indexing and reference
        my $fname = strip-pod6-filename $f;

        # collect the title, ensure first data line is =begin pod,
        # ensure last line is =end pod

        my ($title, $subtitle) = ('', '');
        my $begin = 0;
        my $first = 1;
        my $last  = 0;
        my $s = slurp  $f;
        my @lines = $s.lines;

        # TODO work from top until getting all data,
        #      work from bottom to check =end pod
        # note last element in an array is: @arr[*-1];

        # top down
        my $i = -1;
        while !is-done($begin, $title, $subtitle) {
            ++$i;
            # we limit this to a max of 10 lines
            last if $i > 9;
            my $line = @lines[$i];
            $line = strip-comment $line;
            next if $line !~~ /\S/;

            if $line ~~ /^ \h* '=begin' \h+ pod/ {
                # this should be the first line
                die "FATAL: =begin pod is NOT the first data line"
                    if !$first;
                $first = 0;
                $begin = 1;
            }
            elsif $line ~~ /^ \h* $TITLE / {
                $title = extract-abbrev-block-line $line, :type($TITLE);
            }
            elsif $line ~~ /^ \h* $SUBTITLE / {
                $subtitle = extract-abbrev-block-line $line, :type($SUBTITLE);
            }
        }

        # bottom up
        my $nlines = +@lines;
        my $end = 0;
        $first = 1;
        while !is-done($end) {
            --$nlines;
            ++$i;
            # we limit this to a max of 10 lines
            last if $i > 9;
            my $line = @lines[$nlines];
            $line = strip-comment $line;
            next if $line !~~ /\S/;

            if $line ~~ /^ \h* '=end' \h+ pod/ {
                # this should be the first data line
                die "FATAL: =begin pod is NOT the first data line"
                    if !$first;
            }
            $first = 0;
        }

        # data collected, put in hash
        # hash key: stripped-filename
        #   subkey: title
        #   subkey: subtitle
        %data{$fname}<title>      = $title;
        %data{$fname}<subtitle>   = $subtitle;
    }
}

sub strip-comment($line is copy) {
    my $idx = rindex $line, '#';
    if $idx.defined {
        $line = substr $line, 0, $idx;
    }
    return $line;
}

sub extract-page-order(:begin-pod-line($line)) {
    say "DEBUG: in sub {&?ROUTINE.name}" if $debug;
    my $order = '';
    if $line ~~ /':page-order<' (.*) '>'/ {
        $order = ~$0;
    }
    return $order;
}

sub extract-abbrev-block-line($line is copy, :$type) {
    $line = strip-comment $line;
    die "FATAL: Empty '$type' abbreviated block first line"
        if $line !~~ /\S/;
    my $value = '';
    my $idx = rindex $line, $type;
    if defined $idx {
        my $len = $type.chars;
        $value = substr $line, $idx+$len;
    }
    $value = $value.words.join(' ');

    return $value;
}


sub help {
    say "DEBUG: in sub {&?ROUTINE.name}" if $debug;
    say qq:to/HERE/;
    $usage

    Modes:
        update  - Uses the pod6 source files and the control file
                  ($cfil) to create the .pod6 files with the data
                  for the desired sort order.

        control - Extracts data from original pod files and builds
                  a control file with pertinent data for future operations.
                  The control file is a master list of =TITLEs and base
                  file names for sorting as desired.

                  One of two options must be selected:

                    refresh - updates title data for an existing control file
                    new     - creates a new control file

                  An existing control file ($cfil) cannot be
                  overwritten without permission.

    Options:
        -r      - refresh (for mode 'control')
        -n      - create  (for mode 'control')
        -h      - extended help
        -d      - debug
        -m      - manage (include the categories)

    Note: The modes are selected by entering either the first letter
          of the mode name or its complete name.
    HERE
    exit;
}

sub is-done(*@args) {
    # return False unless all @args elements are true
    for @args -> $v {
        return False if !$v;
    }
    return True;
}

sub write-group-page($group-char, $title, $page-order) {
    my $fname = $todir ~ "/{$page-order}-Group{$group-char}.pod6";
    my $fh = open $fname, :w;

    # note no SUBTITLE
    $fh.print: qq:to/HERE/;
        # THIS FILE IS AUTO-GENERATED--ALL EDITS WILL BE LOST
        =begin pod :class<section-start>
        =TITLE $title
        =SUBTITLE ~
        =end pod
        HERE

    $fh.close;
}

sub EXIT($msg) {
    say "ERROR: $msg";
    exit 1;
}
