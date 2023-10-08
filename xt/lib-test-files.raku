#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Exercise Test-Files command line.

L<xt/lib-test-files.t> invokes this script and its results are reported out through that C<.t> file

=end overview

say 'files';
say Test-Files.files().join(';');
say 'pods';
say Test-Files.pods().join(';');
say 'docs';
say Test-Files.documents().join(';');
say 'tests';
say Test-Files.tests().join(';');
say '---';
