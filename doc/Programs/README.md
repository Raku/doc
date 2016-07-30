Attention contributers
======================

Files in this directory are sorted by file name to generate the index
for the "Programs" tab (in contrast to the other tabs which are
indexed in order by each file's "=TITLE" entry).

Source note
===========

The 00-running.pod file in this directory was copied from

  https://github.com/rakudo/rakudo/tree/nom/docs

in commit:

  ac36d2f7ef63f3b8b7e860d9a08371d476ac1745

on:

  2016-05-06

It was then modified to Perl 6 pod syntax.  At the moment, there
is an error in the Perl 6 pod converter which throws an exception
on leading hyphens in column one of a table row.  The error
can be partially mitigated by escaping the '-', but the
backslash will show in the rendered pod.  Rakudo bug #128221 has
been filed for the error.
