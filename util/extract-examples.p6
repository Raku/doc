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

    if .config<skip-test> {
        return ''
    }else{
        my $catch-all = .config<catch-all> ?? 'CATCH { default {} }' ~ NL !! '';
        my $content = .contents».&walk(@context).trim;
        if ($content.lines.».trim.map( {(.starts-with('multi')  ||
                                         .starts-with('method') ||
                                         .starts-with('proto')  ||
                                         .starts-with('only')   ||
                                         .starts-with('sub'))   &&
                                        (not .ends-with('}'))} ).all) {
            $content = $content.subst("\n", " \{\}\n", :g) ~ ' {' ~ '}';
        }
        return '# ', '=' x 78, NL, 'class :: {', NL, $catch-all, $content, NL, '}';
    }
}

multi sub walk(Pod::Block $_, @context is copy) {
    @context.push: .WHAT;
    walk(.contents, @context)
}

multi sub walk([], @context) { "" }

multi sub walk(@childen, @context) {
    (@childen.map: { walk($_, @context) }).join
}

multi sub walk(Str $s is copy, @context) {
    Pod::Block::Code ~~ any(@context) ?? $s !! ""
}

my &verbose = sub (|c) {};

sub MAIN(Str :$source-path!, Str :$prefix!, Str :$exclude = ".git", Bool :v(:verbose($v)), Bool :$force, *@files) {
    my \exclude = none(flat <. ..>, $exclude.split(','));
    # We exclude these files from examples list
    my @exclude-list = '5to6', 'rb', 'module', 'nativecall', 'testing', 'traps', 'packages', 'tables', 'phasers';

    @files ||= gather for $source-path {
        take .IO when .IO.f
                      && .Str.ends-with('.pod6')
                      && !.basename.starts-with(any @exclude-list);
        .IO.dir(test => exclude)».&?BLOCK when .IO.d
    }

    &verbose = &note if $v;

    for @files».IO -> $file {
        my $out-file-path = IO::Path.new($prefix ~ $file.abspath.substr($source-path.IO.abspath.chars, $file.abspath.chars - $source-path.IO.abspath.chars - 5) ~ '.p6');
        next if !$force && $out-file-path.f && $file.modified < $out-file-path.modified;

        mkdir $out-file-path.volume ~ $out-file-path.dirname;
        $*OUT = open($out-file-path, :w) // die "can not open $out-file-path";

        verbose $out-file-path.Str;

        put 'use v6;';
        put "# begin: $file " ~ "=" x (80 - 10 - $file.chars);
        put 'class {';
        put walk($file);
        put '}';
        put "# end: $file " ~ "=" x (80 - 8 - $file.chars), NL;

        $*OUT.close;
    }
}
