#!/usr/bin/env raku

use Test;
use Test-Files;

=begin overview

Exercise Test-Files command line.

L<xt/lib-test-files.t> invokes this script and its results are reported out through that C<.t> file

=end overview

say Test-Files.files().join(',');
say '---';
say Test-Files.pods().join(',');
say '---';
say Test-Files.documents().join(',');
say '---';
say Test-Files.tests().join(',');
say '---';
