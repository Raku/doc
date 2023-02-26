#!/usr/bin/env raku

# TODO
#   + get desired exit behavior from Coke
#   + settle on table name and output file name

# Global array initially defined in the BEGIN block at the end.
# The array is then defined dynamically by reading the source
# file at https://github.com/Raku/nqp/src/HLL/Grammar.nqp.
our @bracket-chars;

if !@*ARGS {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.IO.basename} go | Reorder [refresh][original][debug]

    Writes the HLL::Grammar '\$brackets' chars into a Pod6 table.

    If the 'Reorder' mode is chosen, the output table is sorted
    by the value of the codepoint of the opening character.
    Otherwise, the order of the source definition is used.

    The HLL::Grammar.nqp file as source is updated if it
    is not found in /util or the 'refresh' option is used.

    Use the 'original' option to use the internal source of
    the brackets.
    HERE
    exit;
}

my $reorder       = 0;
my $refresh       = 0;
my $want-original = 0;
my $debug         = 0;

for @*ARGS {
    when /^ r/ { ++$refresh }
    when /^ R/ { ++$reorder }
    when /^ o/ { ++$want-original }
    when /^ d/ { ++$debug }
}

# The output table file:
my $repopath = $*PROGRAM.IO.absolute.IO.parent(2);
my $fdir1 = $repopath ~ "/doc/Language";
my $f1    = "$fdir1/brackets.pod6";
if $reorder {
    $f1 = "$fdir1/brackets-reordered.pod6";
}

# The local copy of HLL::Grammar.nqp:
my $fdir2 = $repopath ~ "/util";
my $f2    = "$fdir2/Grammar.nqp";

if $debug {
    say "DEBUG: paths:";
    say "  output table: $f1";
    say "  Grammar.nqp : $f2";
    say "Reorder  = $reorder";
    say "original = $want-original";
    say "DEBUG exit"; exit;
}

# Default is to read the Grammar.nqp file:
@bracket-chars = get-brackets(:grammar-file($f2), :$refresh, :$debug) unless $want-original;

write-brackets-pod6-file :table-file($f1), :@bracket-chars, :$reorder, :$debug;

say "Normal end.";
my $of = $f1.IO.relative;
say "See output file '$of'";

sub write-brackets-pod6-file(:$table-file, :@bracket-chars!, :$reorder?, :$debug?) {

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
    HERE

    if $reorder {
        $fh.print: qq:to/HERE/;
        \nThe bracket pairs are arranged in order of the codepoint of the opening bracket.
        HERE
    }
    else {
        $fh.print: qq:to/HERE/;
        \nThe data are arranged in the order found in the source string.
        HERE
    }

    $fh.print: qq:to/HERE/;
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

    if $reorder {
        my %h; # keyed by left bracket int, value is right bracket int
        loop (my $i = 0;  $i < $n; $i += 2)  {
            my Int $Li = @bracket-chars[$i];
            my Int $Ri = @bracket-chars[$i+1];
            %h{$Li} = $Ri;
        }
        my @k = %h.keys.sort({$^a <=> $^b});
        @bracket-chars = [];
        for @k -> $k {
            my $v = %h{$k};
            @bracket-chars.push: $k;
            @bracket-chars.push: $v;
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
        my $ua = HTTP::UserAgent.new;
        $ua.timeout = 10;
        my $api-uri  = "https://raw.githubusercontent.com/Raku/nqp/main/src/HLL/Grammar.nqp";
        my $response = $ua.get($api-uri);
        if $response.is-success {
            spurt $f, $response.content;
        }
        else {
            # TODO determine desired failure response
            die $response.status-line;
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

# TODO eliminate this internal data when the default extraction mode
#      is deemed satisfactory
BEGIN {
    # contents of the following array are the hex values of the HLL::Grammar
    # '$brackets' chars
    @bracket-chars = [
        0x0028, 0x0029, 0x003C, 0x003E, 0x005B, 0x005D,
        # 1 line of 6 = 6
        0x007B, 0x007D, 0x00AB, 0x00BB, 0x0F3A, 0x0F3B, 0x0F3C, 0x0F3D, 0x169B, 0x169C,
        0x2018, 0x2019, 0x201A, 0x2019, 0x201B, 0x2019, 0x201C, 0x201D, 0x201E, 0x201D,
        0x201F, 0x201D, 0x2039, 0x203A, 0x2045, 0x2046, 0x207D, 0x207E, 0x208D, 0x208E,
        0x2208, 0x220B, 0x2209, 0x220C, 0x220A, 0x220D, 0x2215, 0x29F5, 0x223C, 0x223D,
        0x2243, 0x22CD, 0x2252, 0x2253, 0x2254, 0x2255, 0x2264, 0x2265, 0x2266, 0x2267,
        0x2268, 0x2269, 0x226A, 0x226B, 0x226E, 0x226F, 0x2270, 0x2271, 0x2272, 0x2273,
        0x2274, 0x2275, 0x2276, 0x2277, 0x2278, 0x2279, 0x227A, 0x227B, 0x227C, 0x227D,
        0x227E, 0x227F, 0x2280, 0x2281, 0x2282, 0x2283, 0x2284, 0x2285, 0x2286, 0x2287,
        0x2288, 0x2289, 0x228A, 0x228B, 0x228F, 0x2290, 0x2291, 0x2292, 0x2298, 0x29B8,
        0x22A2, 0x22A3, 0x22A6, 0x2ADE, 0x22A8, 0x2AE4, 0x22A9, 0x2AE3, 0x22AB, 0x2AE5,
        0x22B0, 0x22B1, 0x22B2, 0x22B3, 0x22B4, 0x22B5, 0x22B6, 0x22B7, 0x22C9, 0x22CA,
        0x22CB, 0x22CC, 0x22D0, 0x22D1, 0x22D6, 0x22D7, 0x22D8, 0x22D9, 0x22DA, 0x22DB,
        0x22DC, 0x22DD, 0x22DE, 0x22DF, 0x22E0, 0x22E1, 0x22E2, 0x22E3, 0x22E4, 0x22E5,
        0x22E6, 0x22E7, 0x22E8, 0x22E9, 0x22EA, 0x22EB, 0x22EC, 0x22ED, 0x22F0, 0x22F1,
        0x22F2, 0x22FA, 0x22F3, 0x22FB, 0x22F4, 0x22FC, 0x22F6, 0x22FD, 0x22F7, 0x22FE,
        0x2308, 0x2309, 0x230A, 0x230B, 0x2329, 0x232A, 0x23B4, 0x23B5, 0x2768, 0x2769,
        0x276A, 0x276B, 0x276C, 0x276D, 0x276E, 0x276F, 0x2770, 0x2771, 0x2772, 0x2773,
        0x2774, 0x2775, 0x27C3, 0x27C4, 0x27C5, 0x27C6, 0x27D5, 0x27D6, 0x27DD, 0x27DE,
        0x27E2, 0x27E3, 0x27E4, 0x27E5, 0x27E6, 0x27E7, 0x27E8, 0x27E9, 0x27EA, 0x27EB,
        0x2983, 0x2984, 0x2985, 0x2986, 0x2987, 0x2988, 0x2989, 0x298A, 0x298B, 0x298C,
        0x298D, 0x2990, 0x298F, 0x298E, 0x2991, 0x2992, 0x2993, 0x2994, 0x2995, 0x2996,
        0x2997, 0x2998, 0x29C0, 0x29C1, 0x29C4, 0x29C5, 0x29CF, 0x29D0, 0x29D1, 0x29D2,
        0x29D4, 0x29D5, 0x29D8, 0x29D9, 0x29DA, 0x29DB, 0x29F8, 0x29F9, 0x29FC, 0x29FD,
        0x2A2B, 0x2A2C, 0x2A2D, 0x2A2E, 0x2A34, 0x2A35, 0x2A3C, 0x2A3D, 0x2A64, 0x2A65,
        0x2A79, 0x2A7A, 0x2A7D, 0x2A7E, 0x2A7F, 0x2A80, 0x2A81, 0x2A82, 0x2A83, 0x2A84,
        0x2A8B, 0x2A8C, 0x2A91, 0x2A92, 0x2A93, 0x2A94, 0x2A95, 0x2A96, 0x2A97, 0x2A98,
        0x2A99, 0x2A9A, 0x2A9B, 0x2A9C, 0x2AA1, 0x2AA2, 0x2AA6, 0x2AA7, 0x2AA8, 0x2AA9,
        0x2AAA, 0x2AAB, 0x2AAC, 0x2AAD, 0x2AAF, 0x2AB0, 0x2AB3, 0x2AB4, 0x2ABB, 0x2ABC,
        0x2ABD, 0x2ABE, 0x2ABF, 0x2AC0, 0x2AC1, 0x2AC2, 0x2AC3, 0x2AC4, 0x2AC5, 0x2AC6,
        0x2ACD, 0x2ACE, 0x2ACF, 0x2AD0, 0x2AD1, 0x2AD2, 0x2AD3, 0x2AD4, 0x2AD5, 0x2AD6,
        0x2AEC, 0x2AED, 0x2AF7, 0x2AF8, 0x2AF9, 0x2AFA, 0x2E02, 0x2E03, 0x2E04, 0x2E05,
        0x2E09, 0x2E0A, 0x2E0C, 0x2E0D, 0x2E1C, 0x2E1D, 0x2E20, 0x2E21, 0x2E28, 0x2E29,
        0x3008, 0x3009, 0x300A, 0x300B, 0x300C, 0x300D, 0x300E, 0x300F, 0x3010, 0x3011,
        0x3014, 0x3015, 0x3016, 0x3017, 0x3018, 0x3019, 0x301A, 0x301B, 0x301D, 0x301E,
        0xFE17, 0xFE18, 0xFE35, 0xFE36, 0xFE37, 0xFE38, 0xFE39, 0xFE3A, 0xFE3B, 0xFE3C,
        0xFE3D, 0xFE3E, 0xFE3F, 0xFE40, 0xFE41, 0xFE42, 0xFE43, 0xFE44, 0xFE47, 0xFE48,
        0xFE59, 0xFE5A, 0xFE5B, 0xFE5C, 0xFE5D, 0xFE5E, 0xFF08, 0xFF09, 0xFF1C, 0xFF1E,
        0xFF3B, 0xFF3D, 0xFF5B, 0xFF5D, 0xFF5F, 0xFF60, 0xFF62, 0xFF63, 0x27EE, 0x27EF,
        # 38 lines of 10 = 380
        0x2E24, 0x2E25, 0x27EC, 0x27ED, 0x2E22, 0x2E23, 0x2E26, 0x2E27,
        # 1 line of 8 = 8
        # 6 + 380 + 8 = 394
    ];
}
