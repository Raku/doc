# Since the p6doc pod is now moved from 'lib' to 'doc' in the distribution we
# need this to install pod under .../share/perl6/doc
# This fixes p6doc command line use.

use File::Find;

class Build {
    method build($workdir) {
        my $doc-dir   = $workdir.IO.child('doc');
        my $dest-pref = $*REPO.repo-chain.first(*.?can-install).prefix.child("doc");
        mkdir($dest-pref) unless $dest-pref.d;

        my @files = find(dir => "$workdir/doc", type => 'file').list;

        for @files -> $file {
            next if $file.basename eq 'HomePage.pod6';

            my $rel-dest = $file.relative($doc-dir);
            my $abs-dest = IO::Path.new($rel-dest, :CWD($dest-pref)).absolute;

            mkdir($abs-dest.IO.parent) unless $abs-dest.IO.parent.d;

            say "Copying {$rel-dest} to {$abs-dest}";

            copy($file, $abs-dest);
        }
    }
    method isa($what) { # Only needed for older panda compatibility
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
