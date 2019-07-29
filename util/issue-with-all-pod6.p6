#!/usr/bin/env perl6

use v6;

my @docs = qx/git ls-files | grep "\.pod6"/.lines;

say "* [ ] [", $_.split("/")[*-1].split(".")[0], "]($_)" for @docs;
