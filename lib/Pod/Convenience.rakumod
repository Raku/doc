unit module Pod::Convenience;

=begin overview

Provide an C<extract-pod> sub which returns an object containing all the pod
elements from a given file.

=end overview


my $precomp-store = CompUnit::PrecompilationStore::FileSystem.new(:prefix($?FILE.IO.parent(3).child(".pod-precomp")));
my $precomp = CompUnit::PrecompilationRepository::Default.new(store => $precomp-store);

sub extract-pod(IO() $file) is export {
    use nqp;
    # The file name is enough for the id because POD files don't have depends
    my $id = nqp::sha1(~$file);
    my $handle = $precomp.load($id,:since($file.modified))[0];

    if not $handle {
        # precompile it
        $precomp.precompile($file, $id, :force);
        $handle = $precomp.load($id)[0];
    }

    return nqp::atkey($handle.unit,'$=pod')[0];
}

# vim: expandtab shiftwidth=4 ft=perl6
