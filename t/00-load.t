use v6;
use Test;

plan 2;

use-ok 'Pod::To::BigPage', 'load module Pod::To::BigPage';

my $ok = run($*EXECUTABLE-NAME, '-c', 'htmlify.p6');

is $ok.exitcode, 0, 'htmlify compiles';
