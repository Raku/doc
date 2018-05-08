#!/usr/bin/env perl6

use v6;
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

plan 1;

use-ok 'Pod::To::BigPage', 'load module Pod::To::BigPage';
