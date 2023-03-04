#!/usr/bin/env raku

# TODO
#   + get desired exit behavior from Coke
#   + settle on table name and output file name


if !@*ARGS {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.IO.basename} go [refresh][debug]

    Writes the HLL::Grammar '\$brackets' chars into a Pod6 table.

    The HLL::Grammar.nqp file as source is updated if it
    is not found in /util or the 'refresh' option is used.

    You may also define NQP_SRC to use another copy of NQP.
    Ensure that path definition ends at 'nqp' as the checked
    out copy, e.g., 'NQP_ SRC=/some/path/nqp'.
    HERE
    exit;
}

my $refresh       = 0;
my $want-original = 0;
my $debug         = 0;

for @*ARGS {
    when /^ r/ { ++$refresh }
    when /^ d/ { ++$debug }
}

# The output table file:
my $repopath = $*PROGRAM.IO.absolute.IO.parent(2);
my $fdir1 = $repopath ~ "/doc/Language";
my $f1    = "$fdir1/brackets.rakudoc";

# The local copy of HLL::Grammar.nqp:
my $fdir2 = $repopath ~ "/util";
my $f2    = "$fdir2/Grammar.nqp";

if $debug {
    say "DEBUG: paths:";
    say "  output table: $f1";
    say "  Grammar.nqp : $f2";
    say "DEBUG exit"; exit;
}

# This array is defined dynamically by reading the source
# file at https://github.com/Raku/nqp/src/HLL/Grammar.nqp.
my @bracket-chars = get-brackets :grammar-file($f2), :$refresh, :$debug;

write-brackets-rakudoc-file :table-file($f1), :@bracket-chars, :$debug;

say "Normal end.";
my $of = $f1.IO.relative;
say "See output file '$of'";

sub write-brackets-rakudoc-file(:$table-file, :@bracket-chars!, :$reorder?, :$debug?) {

    # The pipe bracket is used to enclose the char pairs in the table.
    # They must be escaped for use on doc site
    my $P = '\\|';

    my $fh = open $table-file, :w;

    $fh.print: qq:to/HERE/;
    =begin pod :kind("Language") :subkind("Language") :category("reference")

    =TITLE Brackets

    =SUBTITLE Valid opening/closing paired delimiters

    The following table shows all of the valid graphemes usable as opening
    and closing paired delimiters in such constructs as I<Pod6 declarator
    blocks>.  Note they are shown between pipe symbols so the extra bounding
    space for any wide characters can be seen.

    The data source for the table is the I<\$brackets> string defined in the
    I<HLL::Grammar> module in the I<github.com/Raku/nqp> repository.

    The data are arranged in the order found in the source string.
    Each opening bracket is shown in its printed form followed by its
    paired closing bracket. Each pair is then followed by its codepoints.
    There are two sets of bracket pairs shown per table row.

    =begin table :caption<Bracket pairs>
     LChar | RChar | LHex  | RHex  | LChar | RChar | LHex  | RHex
    ======+======+======+======+======+======+======+======
    HERE

    my $n = @bracket-chars.elems;
    my $even = $n mod 2 ?? False !! True;
    print "Found $n bracket pair elements ({$n div 2} pairs, " if $debug;
    if $debug {
        if $even {
            say "an even number of elements)."
        }
        else {
            say "an odd number of elements)."
        }
    }

    my $inc = 4; # two pairs per table row
    # We need to march through the list $inc elements at a time
    loop (my $i = 0;  $i < $n; $i += $inc)  {
        my $i0 = $i;
        my $i1 = $i+1;
        my $i2 = $i+2;
        my $i3 = $i+3;

        my ($ai, $bi, $ci, $di); # Int value
        my ($as, $bs, $cs, $ds); # Str value
        my ($ap, $bp, $cp, $dp); # Str value enclosed in pipes
        my ($ax, $bx, $cx, $dx); # hex value

        $ai = $i0 < $n ?? @bracket-chars[$i0] !! '';
        $bi = $i1 < $n ?? @bracket-chars[$i1] !! '';
        $ci = $i2 < $n ?? @bracket-chars[$i2] !! '';
        $di = $i3 < $n ?? @bracket-chars[$i3] !! '';

        $as = $ai ?? $ai.chr !! '';
        $bs = $bi ?? $bi.chr !! '';
        $cs = $ci ?? $ci.chr !! '';
        $ds = $di ?? $di.chr !! '';

        # display the Int values as four-char hex, e.g. 0xAAAA
        $ax = $ai ?? int2hex($ai) !! '';
        $bx = $bi ?? int2hex($bi) !! '';
        $cx = $ci ?? int2hex($ci) !! '';
        $dx = $di ?? int2hex($di) !! '';

        $ap = $ai ?? sprintf("%s%s%s", $P, $as, $P) !! '';
        $bp = $bi ?? sprintf("%s%s%s", $P, $bs, $P) !! '';
        $cp = $ci ?? sprintf("%s%s%s", $P, $cs, $P) !! '';
        $dp = $di ?? sprintf("%s%s%s", $P, $ds, $P) !! '';

        # first pair
        $fh.print: "$ap | $bp | $ax | $bx | ";
        # the second pair may not exist on the last row
        if $cp {
            $fh.say:   "$cp | $dp | $cx | $dx";
        }
        else {
            $fh.say:   "$cp | $dp | $cx |";
        }

        # underline first pair
        $fh.print: "--------+---------+---------+---------+";
        # underline second pair
        $fh.say:   "--------+---------+---------+---------";

        last if !$di;
    }

    $fh.print: qq:to/HERE/;
    =end table
    Z<This file was created by program '/util/{$*PROGRAM.IO.basename}'>
    \n=end pod
    HERE

    $fh.close;
}

sub int2hex($i --> Str) {
    # Convert an Int to hex format
    # Prefer upper-case hex letters
    my $s = sprintf '%#.4X', $i;
    # Prefer lower-case 'x' for string representation
    $s ~~ s/X/x/;
    $s
}

sub get-brackets(:$grammar-file, :$refresh!, :$debug! --> List) {
    # Extracts the data from the nqp/HLL/Grammar.nqp file.
    use HTTP::UserAgent;

    # The local copy of the nqp repo's source file
    my $f = $grammar-file;

    if $refresh or not $f.IO.r {
        # See if there is a local checkout of NQP
        my $end-path = "/src/HLL/Grammar.nqp";
        if %*ENV<NQP_HOME>:exists {
            $f = %*ENV<NQP_HOME> ~ $end-path;
        }
        elsif %*ENV<NQP_SRC>:exists {
            $f = %*ENV<NQP_SRC> ~ $end-path;
        }
        # Otherwise, get it from Github
        else {
            my $ua = HTTP::UserAgent.new;
            $ua.timeout = 10;
            my $uri = "https://raw.githubusercontent.com/Raku/nqp/main" ~ $end-path;
            my $response = $ua.get($uri);
            if $response.is-success {
                spurt $f, $response.content;
            }
            else {
                # TODO determine desired failure response
                die $response.status-line;
            }
        }
    }

    my $bstr = '';
    for $f.IO.lines -> $line {
        # first line of interest:
        #     my $brackets := "\x[0028]\x[0029]\x[003C]\x[003E]\x[005B]\x[005D]" ~
        # an intermediate line:
        #     "\x[3016]\x[3017]\x[3018]\x[3019]\x[301A]\x[301B]\x[301D]\x[301E]" ~
        # last line of interest: note no ending tilde:
        #     "\x[2E24]\x[2E25]\x[27EC]\x[27ED]\x[2E22]\x[2E23]\x[2E26]\x[2E27]"

        if $line ~~ /^:i \h* my \h+ '$brackets' \h+ ':=' \h* '"'
            # the bracket string starts on this line
                       (<[\\\[\]xa..f0..9]>+)
                     '"' \h+ '~' \h*
                    $/ {
            $bstr ~= ~$0
        }
        elsif $line ~~ /^:i \h* '"'
            # the bracket string continues on this line (note ending tilde')
                       (<[\\\[\]xa..f0..9]>+)
                       '"' \h+ '~' \h*
                       $/ {
            $bstr ~= ~$0
        }
        elsif $line ~~ /^:i \h* '"'
            # the bracket string ends on this line (note NO ending tilde')
                       (<[\\\[\]xa..f0..9]>+)
                       '"' \h*
                       $/ {
            $bstr ~= ~$0;
            last
        }
    }

    # say "See \$bstr: $bstr";
    #    \x[FF5B]\x[FF5D]\x[FF5F]\x[FF60]\x[FF62]\x[FF63]\x[27EE]\x[27EF]
    # turn the string into an int array that looks like this:
    #    my @arr = [ 0xFF5B, 0xFF5D, 0xFF5F, 0xFF60, 0xFF62, 0xFF63, 0x27EE, 0x27EF ];

    my @bracket-chars = [];
    my @b = $bstr.comb;
    while @b.elems {
        my $c = '';
        for 1..8 {
            $c ~= @b.shift;
        }
        say "word: '$c'" if $debug;
        # make the 8 chars into an int
        #    transform this form: \x[FF5B]
        #    into this form     : 0xFF5B
        my $b = $c;
        $b ~~ s:g/\\/0/;
        $b ~~ s:g/\[//;
        $b ~~ s:g/\]//;
        say "    word: '$b'; as Int: {$b.Int}" if $debug;
        @bracket-chars.push: $b.Int;
    }
    @bracket-chars
}
