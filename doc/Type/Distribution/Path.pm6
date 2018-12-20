=begin pod

=TITLE class Distribution::Path

=SUBTITLE Distribution::Path

    class Distribution::Path does Distribution::Locally { }

A L<Distribution> implementation backed by the file system. It requires a
C<META6.json> file at its root.

=head1 Methods

=head2 method new

    method new(IO::Path $prefix, IO::Path :$meta-file = IO::Path)

Creates a new C<Distribution::Path> instance from the C<META6.json> file found at the given
C<$prefix>, and from which all paths in the meta data will be prefixed with. C<:$meta-file>
may optionally be passed if a filename other than C<META6.json> needs to be used.

=head2 method meta

    method meta()

Returns a Hash with the representation of the meta data.

=head2 method content

L<Distribution::Locally#method_content>

Returns an C<IO::Handle> to the file represented by C<$name-path>. C<$name-path> is a relative
path as it would be found in the meta data such as C<lib/Foo.pm6> or C<resources/foo.txt>.

=end pod

# vim: expandtab softtabstop=4 shiftwidth=4 ft=perl6
