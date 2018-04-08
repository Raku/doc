# Official Perl 6 Documentation

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

An HTML version of this documentation can be found at [https://docs.perl6.org/](https://docs.perl6.org/).
This is currently the recommended way to consume the documentation.

There is also a command line tool called "p6doc".

(If you are browsing this repository via GitHub, it will not display most
files correctly, because this is Perl 6 Pod, and GitHub assumes Perl 5 POD).

## README in other languages

* [README in Chinese](README.zh.md).

## Install p6doc

This module is available via the Perl 6 module ecosystem. Use

    zef install p6doc

to install the binaries and make it available in your binaries
execution path.

## Use p6doc

With a Rakudo `perl6` executable in `PATH`, try

    ./bin/p6doc Str

to see the documentation for class `Str`, or

    ./bin/p6doc Str.split

to see the documentation for method `split` in class `Str`. You can
skip the `./bin` part if you have installed it via
`zef`. You can also do

    p6doc -f slurp

to browse the documentation of standard functions. Depending on your
disk speed and Rakudo version, it might take a while.

-------

## Building the HTML documentation

Install dependencies by running the following in the checkout directory:

    zef --deps-only install .

If you use [`rakudobrew`](https://github.com/tadzik/rakudobrew), also run the
following, to update the shims for installed executables:

    rakudobrew rehash

In addition to the Perl 6 dependencies, you need to have `graphviz` installed, which
on Debian you can do by running

    sudo apt-get install graphviz

To build the documentation web pages, simply run

    $ make html

Please note that you will need to have [nodejs](https://nodejs.org)
installed to produce HTML content with the above command, in particular
a `node` executable should be in your `PATH`.

After the pages have been generated, you can view them on your local
computer by starting the included `app.pl` program:

    $ make run

You can then view the examples documentation by pointing your web browser at
[http://localhost:3000](http://localhost:3000).

You will need at least [Mojolicious](https://metacpan.org/pod/Mojolicious)
installed and you will need [nodejs](https://nodejs.org) to perform
highlighting. There are also some additional modules you might need;
install them all using

    $ cpanm --installdeps .

---------

## Help Wanted!

Perl 6 is not a small language, and documenting it takes a lot of effort.
Any help is appreciated.

Here are some ways to help us:

 * add missing documentation for classes, roles, methods or operators
 * add usage examples to existing documentation
 * proofread and correct the documentation
 * tell us about missing documentation by opening issues on github.
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
     and not necessarily tied to any specific Perl 6
     implementation.
  2. Implementations' handling of embedded POD is still
     a bit uneven; this avoids potential runtime impacts.
  3. A separate repo in the perl6 Github account invites
     more potential contributors and editors.

**Q:** Should I include methods from superclasses or roles?<br>
**A:** No. The HTML version already includes methods from superclasses and
       roles, and the `p6doc` script will be taught about those as well.

**Q:** Which license is this stuff under?<br>
**A:** Both code and documentation are available under the Artistic License 2.0
       as published by The Perl Foundation. See the [LICENSE](LICENSE) file for the full
       text.

--------

## Vision

> I want p6doc and doc.perl6.org to become the No. 1 resource to consult
> when you want to know something about a Perl 6 feature, be it from the
> language, or built-in types and routines. I want it to be useful to every
> Perl 6 programmer.
>
>    -- moritz

--------

# ENV VARS

- `P6_DOC_TEST_VERBOSE` to a true value to display verbose messages during test suite run.
Helpful when debugging failing test suite.
- `P6_DOC_TEST_FUDGE` fudges `skip-test` code examples as TODO in `xt/examples-compilation.t` test

# LICENSE

See [LICENSE](LICENSE) file for the details of the license of the code in this repository.

This repository also contains code authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/perl6/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
