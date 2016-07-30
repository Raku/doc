#! /usr/bin/env perl6
use v6;

constant \NL = "\n";

multi sub walk(Str :$file) is export {
    walk($file.IO)
}

multi sub walk(IO::Path $io) is export {
    use MONKEY-SEE-NO-EVAL;
    walk(EVAL($io.slurp ~ "\n\$=pod"), [])
}

multi sub walk(Pod::Block::Code $_, @context is copy) {
    @context.push: .WHAT;

    my $content = .contents».&walk(@context).trim;
    '# ', '=' x 78, NL, $content
}

multi sub walk(Pod::Block $_, @context is copy) {
    @context.push: .WHAT;
    walk(.contents, @context)
}

multi sub walk([], @context) { "" }

multi sub walk(@childen, @context) {
    (@childen.map: { walk($_, @context) }).join("\n")
}

multi sub walk(Str $s, @context) {
    Pod::Block::Code ~~ any(@context) ?? $s !! ""
}

my &verbose = sub {};

sub MAIN(Str :$source-path!, Str :$prefix!, Str :$exclude = ".git", Bool :v(:verbose($v))) {
    my \exclude = none(flat <. ..>, $exclude.split(','));
    my @files = gather for $source-path {
        take .IO when .IO.f && .Str.ends-with('.pod6');
        .IO.dir(test => exclude)».&?BLOCK when .IO.d
    }

    &verbose = &note if $v;

    for @files -> $file {
        my $out-file-path = IO::Path.new($prefix ~ $file.substr($source-path.chars, $file.chars - $source-path.chars - 5) ~ '.p6');
        mkdir $out-file-path.volume ~ $out-file-path.dirname;
        $*OUT = open($out-file-path, :w) // die "can not open $out-file-path";

        verbose $out-file-path.Str;
        
        put "# begin: $file " ~ "=" x (80 - 10 - $file.chars);
        put walk $file;
        put "# end: $file " ~ "=" x (80 - 8 - $file.chars), NL;
        
        $*OUT.close;
    }
}
