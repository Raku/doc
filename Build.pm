# Since the p6doc pod is now moved from 'lib' to 'doc' in the distribution we
# need this to install pod under .../share/perl6/doc
# This fixes p6doc command line use.

use v6;
use File::Find;

class Build {
    method build($workdir) {
        my $doc-dir   = $workdir.IO.child('doc');
        my $dest-pref = $*REPO.repo-chain.grep(/site/).first.prefix.child("doc");
        mkdir($dest-pref) unless $dest-pref.d;

        my @files = find(dir => "$workdir/doc", type => 'file').list;
        my $copied-all = True;
        for @files -> $file {
            next if $file.basename eq 'HomePage.pod6';

            my $rel-dest = $file.relative($doc-dir);
            my $abs-dest = IO::Path.new($rel-dest, :CWD($dest-pref)).absolute;

            mkdir($abs-dest.IO.parent) unless $abs-dest.IO.parent.d;

            say "Copying {$rel-dest} to {$abs-dest}";

            copy($file, $abs-dest);
            $copied-all = False unless $abs-dest.IO.e;
        }

        # Zef considers the build to have passed only if a truthy value is returned.
        $copied-all;
    }
    method isa($what) { # Only needed for older panda compatibility
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
