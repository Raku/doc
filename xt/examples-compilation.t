use v6;
use Test;
use File::Temp;

use lib 'lib';
use Pod::Convenience;

my @files;

if @*ARGS {
    @files = @*ARGS;
} else {
    for qx<git ls-files doc>.lines -> $file {
        next unless $file ~~ / '.pod6' $/;
        next if $file ~~ /
            | 'doc/Language/5to6-nutshell.pod6'
            | 'doc/Language/5to6-perlfunc.pod6'
            | 'doc/Language/5to6-perlop.pod6'
            | 'doc/Language/5to6-perlsyn.pod6'
            | 'doc/Language/5to6-perlvar.pod6'
            | 'doc/Language/modules.pod6'
            | 'doc/Language/nativecall.pod6'
            | 'doc/Language/packages.pod6'
            | 'doc/Language/phasers.pod6'
            | 'doc/Language/rb-nutshell.pod6'
            | 'doc/Language/tables.pod6'
            | 'doc/Language/testing.pod6'
            | 'doc/Language/traps.pod6'
         /,
        push @files, $file;
    }
}

# Extract all the examples from the given files
my @examples;
my $counts = BagHash.new;
for @files -> $file {
    for extract-pod($file.IO).contents -> $chunk {
        if $chunk ~~ Pod::Block::Code  {
            next if $chunk.config<skip-test>;
            @examples.push: %(
                'contents', $chunk.contents.join("\n"),
                'file', $file,
                'count', ++$counts{$file}
            );
        }
    }
}

my $proc;
plan +@examples;

for @examples -> $eg {
    my ($filename, $filehandle) = tempfile;

    # Wrap each snippet in an anonymous class, and add in empty routine bodies if needed

    my $code = "class :: \{\n" ~ $eg<contents>.trim.map({
        .starts-with('multi')  ||
        .starts-with('method') ||
        .starts-with('proto')  ||
        .starts-with('only')   ||
        .starts-with('sub')
    }).join("\n") ~ "\n\}";

    $filehandle.print: $code;
    $filehandle.close;

    $proc = run $*EXECUTABLE-NAME, '-c', $filename, out => '/dev/null', err => '/dev/null';
    my $msg = "$eg<file> chunk $eg<count> compiles";
    if $proc.exitcode == 0 {
        pass $msg;
    } else {
        diag $eg<contents>;
        flunk $msg;
    }
}
