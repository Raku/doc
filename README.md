# Official Documentation of Raku

[![Build Status](https://travis-ci.org/Raku/doc.svg?branch=master)](https://travis-ci.org/Raku/doc) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0) [![Run Status](https://api.shippable.com/projects/591e99923f2f790700098a30/badge?branch=master)](https://app.shippable.com/github/Raku/doc) [![CircleCI](https://circleci.com/gh/Raku/doc.svg?style=shield)](https://circleci.com/gh/Raku/doc/tree/master)

An HTML version of this documentation can be found
at [https://docs.raku.org/](https://docs.raku.org/) and also
at [`rakudocs.github.io`](https://rakudocs.github.io) (which is
actually updated more frequently).
This is currently the recommended way to consume the documentation.

This documentation is updated frequently to a GitHub mirror
https://rakudocs.github.io but that might be out of sync with the
official one.

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

* [中文（Chinese）](resources/i18n/zh/README.zh.md)
* [README in Dutch](resources/i18n/nl/README.nl.md)
* [README in French](resources/i18n/fr/README.fr.md)
* [README in German](resources/i18n/de/README.de.md)
* [README in Italian](resources/i18n/it/README.it.md)
* [README in Japanese](resources/i18n/jp/README.jp.md)
* [README in Portuguese](resources/i18n/pt/README.pt.md)
* [README in Spanish](resources/i18n/es/README.es.md)

## Install rakudoc

Please see https://github.com/raku/rakudoc for the
command line tool for viewing the documentation

## Building the HTML documentation

Note: If you just want a copy of the build HTML site and don't want to deal
with the build yourself, you can clone it from here: https://github.com/rakudocs/rakudocs.github.io

The documentation can be rendered to static HTML pages and/or served in a local
web site. This process involves creating a cache of precompiled
documents, so that generation after the first time is sped up.

These are the prerequisites you need to install to generate documentation.

* perl 5.20 or later
* node 10 or later.
* graphviz.
* [Documentable](https://github.com/Raku/Documentable).

Please follow these instructions (in Ubuntu) to install them

    sudo apt install perl graphviz # perl not installed by default in 18.04
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    cpanm --installdeps .
    zef install Documentable

> You can install perl and node any way you want, including version managers, as
> long as they're available to run from the command line.

This should install all needed requisites, now you can clone this repository
and start building process:

    git clone https://github.com/Raku/doc.git # clone the repo
    cd doc # move to the clone of the repo
    # Generate CSS and JS, install highlighting modules, build cache and pages
    make html

You need to do this only the first time to build the cache. When there's some
change in the source (done by yourself or pulled from the repo),

    make update-html

will re-generate only affected pages.

Documentation will be generated in the `html` subdirectory. You can use it
pointing any static web server at that directory, or use the development server
based on Mojolicious using

    make run

This will serve the documentation in port 3000.

## Building the EPUB and/or the "single big page HTML" documentation

The documentation can also be generated in the EPUB format as well as the
"single big page HTML" format. Please note that some features (eg. inherited
methods and type graph in the Types section, or syntax highlighting of the code
examples) are not (yet) available in these formats.

These are the prerequisites you need to install:

* Pod::To::BigPage 0.5.2 or later
* Pandoc (EPUB only)

You can follow these instructions to install them on Ubuntu or Debian:

    zef install "Pod::To::BigPage:ver<0.5.2+>"
    sudo apt install pandoc     # only if you want to generate EPUB

Now that you have the dependencies installed, clone this repository and
generate the EPUB or "single big page HTML" documentation:

    git clone https://github.com/Raku/doc.git # clone this repo
    cd doc      # enter the cloned repo
    make epub           # for the EPUB format,
                        # for the "single big page HTML" format use `make bigpage` instead

The generated EPUB output you will find in the `raku.epub` file in the root of
the repository and the generated "single big page HTML" output in
`html/raku.html`.

## nginx configuration

Latest version of the generated documentation consists only of static
HTML pages. All pages are generated with `.html` at the end; however,
most internal links don't use that suffix. Most web servers (for
instance, the one that serves with GitHub pages) will add it
automatically for you. A bare server will not. This is what you have
to add to the configuration to make it work:

```
    location / {
        try_files $uri $uri/ $uri.html /404.html;
    }
```

This will rewrite the URLs for you. Equivalent configuration might have to be
made in other server applications.

---------

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

**Q:** Why aren't you embedding the docs in the CORE sources?<br>
**A:** Several reasons:

  1. This documentation is intended to be universal with
     respect to a given version of the specification,
     and not necessarily tied to any specific Raku
     implementation.
  2. Implementations' handling of embedded Pod is still
     a bit uneven; this avoids potential runtime impacts.
  3. A separate repo in the Raku Github account invites
     more potential contributors and editors.

**Q:** Should I include methods from superclasses or roles?<br>
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

# UPDATES

Updates are done for the time being by hand. This probably needs improvement.

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
* Examples from Stack Overflow [MIT License](http://creativecommons.org/licenses/MIT); ([ref #1](http://stackoverflow.com/a/43669837/215487) for [1f7cc4e](https://github.com/Raku/doc/commit/1f7cc4efa0da38b5a9bf544c9b13cc335f87f7f6))
* Table sorter plugin from https://github.com/christianbach/tablesorter ;
  [MIT License](http://creativecommons.org/licenses/MIT)
