# p6doc -- an attempt to write something like 'perldoc' for Perl 6

[![Build Status](https://travis-ci.org/perl6/doc.svg?branch=master)](https://travis-ci.org/perl6/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

An HTML version of this documentation can be found at https://docs.perl6.org/.

(If you are browsing this repository via github, it will not display most
files correctly, because this is Perl 6 Pod, and github assumes Perl 5 POD).

With a Rakudo `perl6` executable in `PATH`, try

    ./bin/p6doc Type::Str

to see the documentation for class `Str`, or

    ./bin/p6doc Type::Str.split

to see the documentation for method `split` in class `Str`.

--------

## Building the HTML documentation

To build the documentation web pages, simply run

    $ make html

In addition to the Perl 6 dependencies, you need to have `graphviz` installed.

After the pages have been generated, you can view them on your local
computer by starting the included `app.pl` program:

    $ make run

You can then view the examples documentation by pointing your web browser at
[http://localhost:3000](http://localhost:3000).

You will need at least [Mojolicious](https://metacpan.org/pod/Mojolicious) installed and [Inline::Python](https://metacpan.org/pod/Inline::Python) is recommended
to speed up the syntax highlighting phase.

--------

## Help Wanted!

Perl 6 is not a small language, and documenting it takes a lot of effort.
Any help is appreciated.

Here are some ways to help us:

 * add missing documentation for classes, roles, methods or operators
 * add usage examples to existing documentation
 * proofread and correct the documentation
 * tell us about missing documentation, either by adding it to the WANTED
   file, or by opening issues on github.
 * Do a `git grep TODO` in this repository, and replace the TODO items by
   actual documentation.

The file [WANTED](WANTED) has a list of particular documents that are known
to be missing and [CONTRIBUTING](CONTRIBUTING.md) explains briefly how to
get started contributing documentation.

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

**Q:** Should I include methods from superclasses or roles<br>
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

## Wishlist stuff:

 *  Search terms like `.any`, `any()`, `&any`, `::Any`, etc. can be
    used to disambiguate whether information is sought on a method,
    subroutine, type, etc.

 *  Searching for `Int.Bool` returns the documentation for the
    inherited method `Numeric.Bool`.

 *  Searching for an operator name returns the documentation for
    the operator.  (`p6doc '%%'`  returns the documentation for
    `&infix:<%%>`.)

 *  Perl 6 implementations could embed `P<...>` tags in their source
    code that would then inline the corresponding entry from `p6doc`.
    This would enable things like `&say.WHY` to (dynamically!)
    retrieve the documentation string from `p6doc`, without having
    to duplicate the documentation in the `CORE.setting` sources
    or to encode the documentation into the binaries.

    Example:

        # In Rakudo's src/core/IO.pm:

        #= P<p6doc/&print>
        sub print(|$) { ... }

        #= P<p6doc/&say>
        sub say(|$) { ... }

        #= P<p6doc/&note>
        sub note(|$) { ... }

# LICENSE

See [LICENSE](LICENSE) file for the details of the license of the code in this repository.

This repository also contains code authored by third parties that may be licensed under a different license. Such
files indicate the copyright and license terms at the top of the file. Currently these include:

* jQuery and jQuery UI libraries: Copyright 2015 jQuery Foundation and other contributors; [MIT License](http://creativecommons.org/licenses/MIT)
* [jQuery Cookie plugin](https://github.com/js-cookie/js-cookie):
  Copyright 2006, 2015 Klaus Hartl & Fagner Brack;
  [MIT License](http://creativecommons.org/licenses/MIT)
