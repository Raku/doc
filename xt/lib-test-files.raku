#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;

=begin overview

Exercise Test-Files command line

=end overview

say Test-Files.files().join(',');
say '---';
say Test-Files.pods().join(',');
say '---';
say Test-Files.documents().join(',');
say '---';
say Test-Files.tests().join(',');
say '---';
