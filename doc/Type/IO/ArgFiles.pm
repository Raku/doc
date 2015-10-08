=begin pod

=TITLE class IO::ArgFiles

=SUBTITLE Iterate over contents of files specified on command line

   class IO::ArgFiles is IO::Handle { }

If command line arguments are provided, take them as file names and iterate
over the contents of the files.  If no arguments are specified, process
standard input.

One could print the lines of the files specified on the command line to
standard output using code such as this:

    use v6;

    my $argfiles = IO::ArgFiles.new(args => @*ARGS);

    .say for $argfiles.lines;

Or equivalently by using the C<eof> and C<get> methods:

    use v6;

    my $argfiles = IO::ArgFiles.new(args => @*ARGS);

    while ! $argfiles.eof {
        say $argfiles.get;
    }

Here's the same thing via the C<slurp> method:

    use v6;

    my $argfiles = IO::ArgFiles.new(args => @*ARGS);

    say $argfiles.slurp;

=head1 Variables

=head2 C<$*ARGFILES>

This class is the magic behind the C<$*ARGFILES> variable.  This variable
provides a way to iterate over files passed in to the program on the command
line.  Thus the examples above can be simplified like so:

    use v6;

    .say for $*ARGFILES.lines;

    # or
    while ! $*ARGFILES.eof {
        say $*ARGFILES.get;
    }

    # or
    say $*ARGFILES.slurp;

Save one of the variations in a file, say C<argfiles.p6>.  Then create
another file (named, say C<sonnet18.txt> with the contents:

    Shall I compare thee to a summer's day?

Running the command

    $ perl6 argfiles.p6 sonnet18.txt

will then give the output

    Shall I compare thee to a summer's day?

=head1 Methods

=head2 method eof

Return C<True> if the end of the file has been reached, otherwise C<False>.

=head2 method get

Return one line of the open file handle.

=head2 method lines

Return a (lazy) list of the remaining lines in the file pointed to by the
file handle.

=head2 method slurp

Slurp the entire contents of the file into a string.

=head2 method nl

The newline character for the file.  By default this is C<\n>.

=head1 Related roles and classes

See also the related role L<IO> and the related class L<IO::Handle>.

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
