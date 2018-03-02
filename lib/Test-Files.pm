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

# vim: expandtab shiftwidth=4 ft=perl6
