unit class Test-Files;

=begin overview

Provide methods to generate a list of all C<files>, C<pod> documents,
all C<documents> (POD and markdown), and C<tests> based on the output
of C<git ls-files>.

If the environment variable TEST_FILES is set, it's treated a space
separate list of files to use instead. Files are trimmed from the list
if they don't exist.

If files were passed on the command line, use that list (as is) instead.

=end overview

method files() {
    my @files;

    if @*ARGS {
        @files = @*ARGS;
    } else {
        if %*ENV<TEST_FILES> {
            @files = %*ENV<TEST_FILES>.trim.split(/ \s /).grep(*.IO.e);
        } else {
            @files = qx<git ls-files>.lines;
        }
    }
    return @files.sort;
}

method pods() {
    return $.files.grep({$_.ends-with: '.pod6'})
}

method documents() {
    return $.files.grep({$_.ends-with: '.pod6' or $_.ends-with: '.md'})
}

method tests() {
    return $.files.grep({$_.ends-with: '.t'})
}

# vim: expandtab shiftwidth=4 ft=perl6
