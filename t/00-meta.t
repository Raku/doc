#!/usr/bin/env raku

use v6;
use lib $*PROGRAM.parent(2).child('lib');
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test::META;
meta-ok;

done-testing;
