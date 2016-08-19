# Contributing

Your patches to perl6/doc are very welcome.

This document describes how to get started and helps to provide documentation
that adheres to the common style and formatting guidelines.

Your contributions will be credited in Rakudo release announcement. You name from
the commit log will be used. If you'd like to be credited under a different name,
please add it to [CREDITS file](https://github.com/rakudo/rakudo/blob/nom/CREDITS)

If you have any questions regarding contributing to this project, please ask
in the [#perl6 IRC channel](https://perl6.org/community/irc).

# TABLE OF CONTENTS
- [General principles](#general-principles)
- [Documenting types](#documenting-types)
- [Testing examples](#testing-examples)
    - [Skipping tests](#skipping-tests)
- [Debug mode](#debug-mode)
    - [Invisible index anchors](#invisible-index-anchors)
    - [Viewport size](#viewport-size)
    - [Broken links](#broken-links)
    - [Heading numbering](#heading-numbering)
- [Reporting bugs](#reporting-bugs)
- [Website Styles](#website-styles)
- [Building the documentation](#building-the-documentation)
    - [Dependency installation](#dependency-installation)
        - [Rakudo](#rakudo)
        - [Panda](#panda)
        - [Pod::To::HTML](#podtohtml)
        - [Mojolicious / Web Server](#mojolicious--web-server)
        - [pygmentize](#pygmentize)
        - [Inline::Python](#inlinepython)
    - [Build and view the documentation](#build-and-view-the-documentation)

## General principles

* Please use the present tense, and [active voice](https://en.wikipedia.org/wiki/Active_voice).
* Link to external resources (like Wikipedia) for topics that are not
  directly related to Perl 6 (like the math that our routines implement)
* Duplicate small pieces of information rather than rely on linking
* Be explicit about routine signatures. If a method accepts a `*%args`,
  but treats some of them specially, list them separately.
* Check out [the styleguide](STYLEGUIDE.md) for further guidance
* For website: we support the current and previous major releases of Chrome, Firefox,
Internet Explorer (Edge), and Safari. Please test layout changes.
Lacking actual browsers to test in, you can use [browsershots.org](http://browsershots.org)
or [browserstack.com](http://browserstack.com). Ensure the layout looks OK on mobile.

## Documenting types

The POD documentation of types is located in the `doc/Type` directory and
subdirectories of this repository. For example the POD of `X::Bind::Slice`
lives in `doc/Type/X/Bind/Slice.pod6`.

To start contributing fork and checkout the repository, find the document
you want to improve, commit your changes, and create a pull request. Should
questions come up in the process feel free to ask in
[#perl6 IRC channel](https://perl6.org/community/irc).

If the documentation for a type does not exist create the skeleton of the doc
with the helper tool `util/new-type.p6`. Say you want to create `MyFunnyRole`:

    $ perl6 util/new-type.p6 MyFunnyRole

Fill the documentation file `doc/Type/MyFunnyRole.pod6` like this:

    =TITLE role MyFunnyRole

    =SUBTITLE Sentence or half-sentence about what it does

        role MyFunnyRole does OtherRole is SuperClass { ... }

    Longer description here about what this type is, and
    how you can use it.

        # usage example goes here

    =head1 Methods

    =head2 method do-it

        method do-it(Int $how-often) returns Nil:D

    Method description here

        MyFunnyRole.do-it(2);   # example output


When documenting a pair of a sub and a method which both do the same thing, the
heading should be `=head2 routine do-it`, and the next thing should be two or
more lines with the signatures. Other allowed words instead of `method` are
`sub`, `trait`, `infix`, `prefix`, `postfix`, `circumfix`, `postcircumfix`,
`term`. If you wish to hide a heading from any index prefix it with the empty
comment `Z<>`.

## Testing examples

To export examples from all .pod6-files use `make extract-examples`. To run
individual tests pick the right .p6-file from `examples/` as a parameter to
`perl6`.

### Skipping tests

Some examples fail with compile time exceptions and would interrupt the test
for a file. Use the pod-config option `skip-test` to skip them.

    =begin code :skip-test
        your-example-here();
    =end code

## Testing method completeness

To get a list of methods that are found via introspection but not found in any
pod6 under `doc/Type/`, use `util/list-missing-methods.p6`. It takes a
directory or filepath as argument and limits the listing to the given file or
any pod6-files found. All methods listed in `util/ignored-methods.txt` are
ignored.

## Debug mode

On the right side of the footer you can find [Debug: off]. Click it and reload
the page to activate debug mode. The state of debug mode will be remembered by
`window.sessionStorage` and will not survive a brower restart or opening the
docs in a new tab.

### Invisible index anchors

You can create index entries and invisible anchors with `X<|somename,some
category>`. To make them visible activate debug mode.

### Viewport size

If you change the layout please check different screen sizes. Debug mode will
display the viewport size in the bottom left corner.

### Broken links

To check for broken links use debug mode. Any spotted broken link will be
listed under the search input. Please note that some external links may not get
checked depending on your browser settings.

### Heading numbering

Please check if the heading you add are of sound structure. You can use debug mode
to display heading numbers.

## Reporting bugs

Report issues at https://github.com/perl6/doc/issues. You can use the
following labels when tagging tickets:

* site   - presentation issue with the website (e.g. invalid HTML)
* docs   - missing or incorrect documentation
* build  - scripts or libraries that generate the site
* search - the search component

* LHF    - for a beginner to work on
* big    - a big issue, may require some research

## Website Styles

The `html/css/style.css` file is built from `assets/sass/style.sass`. Please
don't edit `html/css/style.css` directly, as your changes will be lost
the next time the SASS file is processed.

[SASS](http://sass-lang.com/) is a superset of CSS, so if you don't know SASS,
just write in regular CSS. Run `app.pl` to automatically process SASS and copy
the result over to `html/css/style.css`

## Building the documentation

Assuming that you have already forked and cloned the
[perl6/doc](https://github.com/perl6/doc) repository, one of the first things
you probably want to do is to build the documentation on your local
computer.  To do this you will need:

  - Rakudo (the Rakudo Perl 6 implementation)
  - Panda (the installer for third party Perl 6 modules)
  - `Pod::To::HTML` (Perl 6 module for converting Pod objects to HTML)
  - [graphviz](http://www.graphviz.org/) (`sudo apt-get install graphviz` on Debian/Ubuntu)
  - [Mojolicious](https://metacpan.org/pod/Mojolicious)
    (optional; a Perl 5 web framework; it allows you to run a web
    app locally to display the docs)
  - pygmentize (optional; a program to add syntax highlighting to code
    examples)
  - `Inline::Python` (optional; run Python code from within Perl 6,
    necessary for faster execution of pygmentize)

### Dependency installation

#### Rakudo

Install Rakudo via [rakudobrew](https://github.com/tadzik/rakudobrew).

Clone the `rakudobrew` repository

    $ git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew

and add `rakudobrew` to your `PATH` (also add this line to e.g. `~/.profile`):

    $ export PATH=~/.rakudobrew/bin:$PATH

To build the Rakudo Perl 6 implementation with the MoarVM backend, simply
run

    $ rakudobrew build moar

If everything is set up correctly, the executable `perl6` should be in your
`PATH`.  As a simple test, run `perl6` and see if the
[REPL](http://en.wikipedia.org/wiki/Read-eval-print_loop) prompt appears:

    $ perl6
    >

Exit the REPL by pressing `Ctrl-d` or typing `exit` at the prompt.

#### Panda

After `rakudobrew` is installed, installing `panda` is very easy:

    $ rakudobrew build panda

Now the `panda` command should be available.

#### Pod::To::HTML

The program that builds the HTML version of the documentation
(`htmlify.p6`) uses `Pod::To::HTML` to convert Pod structures into HTML.
You'll also need `Pod::To::BigPage`. Install these modules like so:

    $ panda install Pod::To::HTML Pod::To::BigPage

#### Mojolicious / Web Server

This is a Perl 5 web framework which is used to run the included
web application that displays the HTML documentation in a web browser. It's
no required for development, as the site is static and you can serve it using
any other webserver.

The app *does* automatically convert the SASS file to CSS, so it's handy to
use for that as well.

Mojolicious is written in Perl 5, so assuming that you use
[`cpanm`](https://metacpan.org/pod/App::cpanminus),
install this now:

    $ cpanm -vn Mojolicious

If you also plan on modifying the SASS stylesheets, install these modules to
enable SASS processor:

    $ cpanm -vn CSS::Sass Mojolicious::Plugin::AssetPack

Alternatively, you can install `sass` program and process SASS using that instead:

    $ sass -w assets/sass/style.scss:html/css/style.css

#### pygmentize

This program adds syntax highlighting to the code examples.  Highlighting of
Perl 6 code was added in version 2.0, so you need at least this version if
you wish to produced syntax highlighted documentation on your local
computer.

If you use Debian/Jessie, you can install `pygmentize` via the
`python-pygments` package:

    $ aptitude install python-pygments

On Ubuntu install the package `python-pygments`:

    $ sudo apt-get install python-pygments

On Fedora the package is also named `python-pygments`:

    $ sudo yum install python-pygments

Otherwise, you probably need to use [`pip`](https://pip.pypa.io/en/latest/)
(the Python package installer):

    $ pip install pygmentize

#### Inline::Python

`Inline::Python` is optional, however will speed up documentation builds
using syntax highlighting.

First, you'll need the Python Devel header files and libraries if they have not
already been installed:

On Debian, install the `python-dev` package:

    aptitude install python-dev

On Ubuntu, the package is also named `python-dev`:

    sudo apt-get install python-dev

On Fedora, install the `python-devel` package:

    sudo yum install python-devel

Use `panda` to install the `Inline::Python` module:

    $ panda install Inline::Python

### Build and view the documentation

To actually build the documentation all you now need to do is run
`htmlify.p6`:

    $ perl6 htmlify.p6

This takes a while, but be patient!

After the build has completed, you can start the web application which will
render the HTML documentation

    $ perl app.pl daemon   # note!  Perl 5 *not* Perl 6 here

Now point your web browser to http://localhost:3000 to view the
documentation.
