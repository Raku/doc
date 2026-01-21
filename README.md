# Official Documentation of Raku™

[![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)
[![test](https://github.com/Raku/doc/actions/workflows/test.yml/badge.svg)](https://github.com/Raku/doc/actions/workflows/test.yml)

An HTML version of this documentation can be found
at [https://docs.raku.org/](https://docs.raku.org/).
That site is updated from the main branch here
frequently (but not continuously).

This is currently the recommended way to consume the documentation. The tooling
to build and run this site is [available on github](https://github.com/Raku/doc-website).

This repository is not intended to be installed as a module. When running tests or
scripts locally, you may need to set ``RAKULIB=.``

## README in other languages

  [日本語](resources/i18n/jp/README.jp.md)
| [普通话](resources/i18n/zh/README.zh.md)
| [Deutsch](resources/i18n/de/README.de.md)
| [español](resources/i18n/es/README.es.md)
| [français](resources/i18n/fr/README.fr.md)
| [italiano](resources/i18n/it/README.it.md)
| [nederlands](resources/i18n/nl/README.nl.md)
| [Português](resources/i18n/pt/README.pt.md)

## Help Wanted!

[Interested in contributing?](writing-docs/README.md)

## Why aren't the docs embedded in the compiler source?

  1. This documentation is intended to be universal with
     respect to the specification, and not tied to any specific
     implementation.
  2. Implementations' handling of embedded Pod is still
     a bit uneven; this avoids potential runtime impacts.
  3. This separate repo in the Raku Github account invites
     more potential contributors and editors.

## rakudoc

There is a [CLI](https://github.com/Raku/rakudoc) for viewing Raku documentation.

## Vision

> I want p6doc and docs.raku.org to become the No. 1 resource to consult
> when you want to know something about a Raku feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Raku programmer.
>
>    -- moritz

# LICENSE

The documentation and code in this repository is available under the Artistic License 2.0
as published by [The Perl & Raku Foundation (TPRF)](https://rakufoundation.org).
See the [LICENSE](LICENSE) file for the full text.

This repository may also contain examples authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* Examples from Stack Overflow; [MIT License](http://creativecommons.org/licenses/MIT) ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/Raku/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
