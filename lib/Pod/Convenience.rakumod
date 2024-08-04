unit module Pod::Convenience;

=begin overview

Provide C<&extract-pod> which returns an object containing all the pod
elements from a given file.

=end overview

# "File" class was deprecated; use the FileSystem if it's available, fall back to deprecated if not.
# (should now work on both new and old rakudos, avoiding deprecation notice where possible
my $class = ::("CompUnit::PrecompilationStore::FileSystem");
if $class ~~ Failure {
    $class = ::("CompUnit::PrecompilationStore::File");
}

my $precomp-store = $class.new(:prefix($?FILE.IO.parent(3).child(".pod-precomp")));
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
