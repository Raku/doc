unit class Test-Files;

method files() {
    my @files;

    if @*ARGS {
        @files = @*ARGS;
    } else {
        if %*ENV<TEST_FILES> {
            @files = %*ENV<TEST_FILES>.trim.split(' ').grep(*.IO.e);
        } else {
            @files = qx<git ls-files>.lines;
        }
    }
    return @files;
}

method pods() {
    return $.files.grep({$_.ends-with: '.pod6'})
}

method documents() {
    return $.files.grep({$_.ends-with: '.pod6' or $_.ends-with: '.md'})
}

# vim: expandtab shiftwidth=4 ft=perl6
