# Official Documentation of Raku™

[![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)
[![CircleCI](https://circleci.com/gh/Raku/doc/tree/master.svg?style=svg)](https://circleci.com/gh/Raku/doc/tree/master)
[![test](https://github.com/Raku/doc/actions/workflows/test.yml/badge.svg)](https://github.com/Raku/doc/actions/workflows/test.yml)

An HTML version of this documentation can be found
at [https://docs.raku.org/](https://docs.raku.org/).

This is currently the recommended way to consume the documentation.

## Docker container

This documentation is also published as
the
[`jjmerelo/perl6-doc`](https://hub.docker.com/r/jjmerelo/perl6-doc) Docker
container. It includes a copy of the web published on port 3000, so you
can run it with:

    docker run --rm -it -p 3000:3000 jjmerelo/perl6-doc

or

    docker run --rm -it -p 31415:3000 jjmerelo/perl6-doc

in case you want it published somewhere else. You can direct your
browser to `http://localhost:3000` (or 31415, as the case may be).

## README in other languages

* [README in Chinese](resources/i18n/zh/README.zh.md)
* [README in Dutch](resources/i18n/nl/README.nl.md)
* [README in French](resources/i18n/fr/README.fr.md)
* [README in German](resources/i18n/de/README.de.md)
* [README in Italian](resources/i18n/it/README.it.md)
* [README in Japanese](resources/i18n/jp/README.jp.md)
* [README in Portuguese](resources/i18n/pt/README.pt.md)
* [README in Spanish](resources/i18n/es/README.es.md)

## Install rakudoc

Please see https://github.com/Raku/rakudoc for the
command line tool for viewing the documentation.

## Building the HTML documentation

Building the website from the raw documentation is done using the tooling
at https://github.com/Raku/doc-website

## Help Wanted!

Raku is not a small language, and documenting it and maintaining that
documentation takes a lot of effort. Any help is appreciated.

Here are some ways to help us:

 * Add missing documentation for classes, roles, methods or operators.
 * Add usage examples to existing documentation.
 * Proofread and correct the documentation.
 * Tell us about missing documentation by opening issues on Github.
 * Do a `git grep TODO` in this repository, and replace the TODO items by
   actual documentation.

[Issues page](https://github.com/Raku/doc/issues) has a list of current issues and
documentation parts that are known to be missing
and [the CONTRIBUTING document](CONTRIBUTING.md)
explains briefly how to get started contributing documentation.

--------

## Some notes:

**Q:** Why aren't you embedding the docs in the CORE sources?<br />
**A:** Several reasons:

  1. This documentation is intended to be universal with
     respect to a given version of the specification,
     and not necessarily tied to any specific Raku
     implementation.
  2. Implementations' handling of embedded Pod is still
     a bit uneven; this avoids potential runtime impacts.
  3. A separate repo in the Raku Github account invites
     more potential contributors and editors.

**Q:** Should I include methods from superclasses or roles?<br />
**A:** No. The HTML version already includes methods from superclasses and
       roles.

--------

## Vision

> I want p6doc and docs.raku.org to become the No. 1 resource to consult
> when you want to know something about a Raku feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Raku programmer.
>
>    -- moritz

--------

# ENV VARS

- `P6_DOC_TEST_VERBOSE` to a true value to display verbose messages during test suite run.
Helpful when debugging failing test suite.
- `P6_DOC_TEST_FUDGE` fudges `skip-test` code examples as TODO in `xt/examples-compilation.t` test.

# LICENSE

The code in this repository is available under the Artistic License 2.0
as published by The Perl Foundation. See the [LICENSE](LICENSE) file for the full
text.

This repository also contains code authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow; [MIT License](http://creativecommons.org/licenses/MIT) ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/Raku/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter;
  [MIT License](http://creativecommons.org/licenses/MIT)
