# Since the p6doc pod is now moved from 'lib' to 'doc' in the distribution we
# need this to install pod under .../share/perl6/doc
# This fixes p6doc command line use.

use Panda::Common;
use Panda::Builder;
use Shell::Command;
use File::Find;
use Panda::Installer;

class Build is Panda::Builder {
    method build($workdir) {

        my $dest-pref = Panda::Installer.new.default-prefix() ~ '/../doc';

        my @files = find(dir => "$workdir/doc", type => 'file').list;

        for @files -> $file {
            next if $file ~~ /'HomePage.pod'$/;

            my $dest = $file;
            $dest =  $dest-pref ~ $dest.split("$workdir/doc")[1];

            my $dest-dir = $dest.IO.dirname;
            mkpath $dest-dir unless $dest-dir.IO.d;

            my $relative = $*SPEC.abs2rel($file, $workdir);
            note "Copying $relative to $dest";

            cp($file, $dest);
        }
    }
}
