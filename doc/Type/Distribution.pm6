=begin pod

=TITLE role Distribution

=SUBTITLE Distribution

    role Distribution { }

Interface for objects that provide API access mapping META6 data to the files its represents.
Objects that fulfill the C<Distribution> role can be read by e.g. L<CompUnit::Repository::Installation>.
Generally a C<Distribution> provides read access to a set of modules and meta data. These
may be backed by the file system (L<Distribution::Path>, L<Distribution::Hash>) but could
also read from a e.g. tar file or socket.

=head1 Required Methods

=head2 method meta

    method meta(--> Hash:D) { ... }

Returns a Hash with the representation of the meta data. Please note that an actual META6.json
file does not need to exist, just a representation in that format.

=head2 method content

    method content($name-path --> IO::Handle:D) { ... }

Returns an C<IO::Handle> to the file represented by C<$name-path>. C<$name-path> is a relative
path as it would be found in the meta data such as C<lib/Foo.pm6> or C<resources/foo.txt>.

=end pod

# vim: expandtab softtabstop=4 shiftwidth=4 ft=perl6
