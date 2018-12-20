=begin pod

=TITLE class Distribution::Hash

=SUBTITLE Distribution::Hash

    class Distribution::Hash does Distribution::Locally { }

A L<Distribution> implementation backed by the file system. It does not require a
a C<META6.json> file, essentially providing a lower level C<Distribution::Path>.

=head1 Methods

=head2 method new

    method new($hash, :$prefix)

Creates a new C<Distribution::Hash> instance from the meta data contained in C<$hash>.
All paths in the meta data will be prefixed with C<:$prefix>.

=head2 method meta

    method meta()

Returns a Hash with the representation of the meta data.

=head2 method content

L<Distribution::Locally#method_content>

Returns an C<IO::Handle> to the file represented by C<$name-path>. C<$name-path> is a relative
path as it would be found in the meta data such as C<lib/Foo.pm6> or C<resources/foo.txt>.

=end pod

# vim: expandtab softtabstop=4 shiftwidth=4 ft=perl6
