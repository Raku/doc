# Official Documentation of Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0) [![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/perl6/doc)

An HTML version of this documentation can be found at [https://docs.perl6.org/](https://docs.perl6.org/).
This is currently the recommended way to consume the documentation.

There is also a command line tool called `p6doc`, which you can use to
browse the documentation once it's installed (see below).

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
browser to http://localhost:3000 (or 31415, as the case may be).


## README in other languages

* [README in Chinese](resources/i18n/zh/README.zh.md)
* [README in Dutch](resources/i18n/nl/README.nl.md)
* [README in French](resources/i18n/fr/README.fr.md)
* [README in German](resources/i18n/de/README.de.md)
* [README in Italian](resources/i18n/it/README.it.md)
* [README in Japanese](resources/i18n/jp/README.jp.md)
* [README in Portuguese](resources/i18n/pt/README.pt.md)
* [README in Spanish](resources/i18n/es/README.es.md)

## Install p6doc

This module is available via the Perl 6 module ecosystem. Use:

    $ zef install p6doc

to install the "binaries" and make them available in your binaries
execution path.

**Note**: Please note that, due to changes in the parsing of Pod6,
this will fail in versions of Perl 6 older than 2018.06. Please upgrade to that
version, or install using `--force`.

## Use p6doc

With a Rakudo `perl6` executable in the `PATH`, try:

    $ ./bin/p6doc Str

to see the documentation for class `Str`, or:

    $ ./bin/p6doc Str.split

to see the documentation for method `split` in class `Str`. You can
skip the `./bin` part if you have installed it via
`zef`. You can also do:

    $ p6doc -f slurp

to browse the documentation of standard functions (which, in this
particular case, will actually return multiple matches, which you can
check individually). Depending on your
disk speed and Rakudo version, it might take a while.

-------

## Building the HTML documentation

You might want to have a copy of the documentation and run the web
site locally yourself. In that case, install dependencies by running
the following in the checkout directory:

    $ zef --deps-only install .

If you use [`rakudobrew`](https://github.com/tadzik/rakudobrew), also run the
following, to update the shims for installed executables:

    $ rakudobrew rehash

In addition to the Perl 6 dependencies, you need to have `graphviz` installed, which
on Debian you can do by running:

    $ sudo apt-get install graphviz

To build the documentation web pages, simply run:

    $ make html

> For best results, we recommend that you use the latest released versions, specially any one after 2018.11.


Please note that you will need to have [nodejs](https://nodejs.org)
installed to produce HTML content with the above command, in particular
a `node` executable should be in your `PATH`. Besides, you will need
to have `g++` installed in order to build some of the dependencies
that are installed with nodejs. nodejs is needed only to apply
highlighting to the included code; if you do not want that, simply
write

    $ make html-nohighlight

After the pages have been generated, you can view them on your local
computer by starting the included `app.pl` program:

    $ make run

You can then view the examples documentation by pointing your web browser at
[http://localhost:3000](http://localhost:3000).

You will need at least [Mojolicious](https://metacpan.org/pod/Mojolicious)
installed and you will need [nodejs](https://nodejs.org) to perform
highlighting. There are also some additional modules you might need;
install them all using:

    $ cpanm --installdeps .

If you have `pandoc` installed, you can also generate an ePub with

    $ make epub

---------

## Help Wanted!

Perl 6 is not a small language, and documenting it takes a lot of effort.
Any help is appreciated.

Here are some ways to help us:

 * Add missing documentation for classes, roles, methods or operators.
 * Add usage examples to existing documentation.
 * Proofread and correct the documentation.
 * Tell us about missing documentation by opening issues on Github.
 * Do a `git grep TODO` in this repository, and replace the TODO items by
   actual documentation.

[Issues page](https://github.com/perl6/doc/issues) has a list of current issues and
documentation parts that are known to be missing
and [the CONTRIBUTING document](CONTRIBUTING.md)
explains briefly how to get started contributing documentation.

--------

## Some notes:

**Q:** Why aren't you embedding the docs in the CORE sources?<br>
**A:** Several reasons:

  1. This documentation is intended to be universal with
     respect to a given version of the specification,
     and not necessarily tied to any specific Perl 6
     implementation.
  2. Implementations' handling of embedded Pod is still
     a bit uneven; this avoids potential runtime impacts.
  3. A separate repo in the perl6 Github account invites
     more potential contributors and editors.

**Q:** Should I include methods from superclasses or roles?<br>
**A:** No. The HTML version already includes methods from superclasses and
       roles, and the `p6doc` script will be taught about those as well.

--------

## Vision

> I want p6doc and docs.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Perl 6 programmer.
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
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
