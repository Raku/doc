#!/usr/bin/env raku

use Test;
use lib $*PROGRAM.parent(2).child('lib');

=begin overview

Test the Test-Files module

=end overview

plan 25;
use-ok 'Test-Files';

use Test-Files;

# We could ourselves be running with TEST_FILES set - ignore it for now...
%*ENV<TEST_FILES>='';

my @files = Test-Files.files();
ok @files.elems > 1, '.files returns something array-like with at least one item';
ok all(@files.map(*.IO.f)), 'all files returned exist';

my @pods = Test-Files.pods();
ok @pods.elems > 1, '.pods returns something array-like with at least one item';
ok all(@pods>>.ends-with('.pod6')), 'all files returned are pod files';
ok all(@pods.map(*.IO.f)), 'all files returned exist';

my @docs = Test-Files.documents();
ok @docs.elems > 1, '.documents returns something array-like with at least one item';
ok all(@docs>>.ends-with('.pod6'|'.md')), 'all files returned are pod/md files';
ok all(@docs.map(*.IO.f)), 'all files returned exist';

my @tests = Test-Files.tests();
ok @tests.elems > 1, '.tests returns something array-like with at least one item';
ok all(@tests>>.ends-with('.t')), 'all files returned are test files';
ok all(@tests.map(*.IO.f)), 'all files returned exist';

my $expected = q:to/END/;
foo,foo.md,foo.pod6,foo.t
---
foo.pod6
---
foo.md,foo.pod6
---
foo.t
---
END

is run($*EXECUTABLE, 'xt/lib-test-files.raku', 'foo.t', 'foo.pod6', 'foo.md', 'foo', :out).out.slurp(:close), $expected, 'correct (sorted) output from command line usage';

# Now test the specific TEST_FILES we want...
%*ENV<TEST_FILES>='this-file-does-not-exist xt/lib-test-files.t';
is Test-Files.files, 'xt/lib-test-files.t', 'TEST_FILES 1 skip missing files, keep existing';
is Test-Files.pods, '', 'TEST_FILES 1 skip missing files, bad type';
is Test-Files.documents, '', 'TEST_FILES 1 skip missing files, bad type';
is Test-Files.tests, 'xt/lib-test-files.t', 'TEST_FILES 1 skip missing files, keep existing type match';

%*ENV<TEST_FILES>='this-file-does-not-exist CONTRIBUTING.md';
is Test-Files.files, 'CONTRIBUTING.md', 'TEST_FILES 2 skip missing files, keep existing';
is Test-Files.pods, '', 'TEST_FILES 2 skip missing files, bad type';
is Test-Files.documents, 'CONTRIBUTING.md', 'TEST_FILES 2 skip missing files, keep existing type match';
is Test-Files.tests, '', 'TEST_FILES 2 skip missing files, bad type';

%*ENV<TEST_FILES>='this-file-does-not-exist doc/Type/Mu.pod6';
is Test-Files.files, 'doc/Type/Mu.pod6', 'TEST_FILES 3 skip missing files, keep existing';
is Test-Files.pods, 'doc/Type/Mu.pod6', 'TEST_FILES 3 skip missing files, keep existing type match';
is Test-Files.documents, 'doc/Type/Mu.pod6', 'TEST_FILES 3 skip missing files, keep existing type match';
is Test-Files.tests, '', 'TEST_FILES 3 skip missing files, bad type';

