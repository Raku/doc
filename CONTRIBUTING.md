# Contributing

Your patches to perl6/doc are very welcome.

This document describes how to get started and helps to provide documentation
that adheres to the common style and formatting guidelines.

Your contributions will be credited in Rakudo release announcement. You name from
the commit log will be used. If you'd like to be credited under a different name,
please add it to [CREDITS file](https://github.com/rakudo/rakudo/blob/master/CREDITS)

If you have any questions regarding contributing to this project, please ask
in the [#perl6 IRC channel](https://perl6.org/community/irc).

# TABLE OF CONTENTS
- [General principles](#general-principles)
- [Writing code examples](#writing-code-examples)
- [Documenting types](#documenting-types)
- [Writing and Testing Examples](#writing-and-testing-examples)
- [Debug mode](#debug-mode)
    - [Invisible index anchors](#invisible-index-anchors)
    - [Viewport size](#viewport-size)
    - [Broken links](#broken-links)
    - [Heading numbering](#heading-numbering)
- [Reporting bugs](#reporting-bugs)
- [Building the documentation](#building-the-documentation)
    - [Dependency installation](#dependency-installation)
        - [Rakudo](#rakudo)
        - [Zef](#zef)
        - [Pod::To::HTML](#podtohtml)
        - [Mojolicious / Web Server](#mojolicious--web-server)
        - [SASS compiler](#sass-compiler)
    - [Build and view the documentation](#build-and-view-the-documentation)
        - [Using Docker](#using-docker-to-build-and-view-the-documentation)

## General principles

* Please use the present tense, and [active voice](https://en.wikipedia.org/wiki/Active_voice).
* Link to external resources (like Wikipedia) for topics that are not
  directly related to Perl 6 (like the math that our routines implement).
* Duplicate small pieces of information rather than rely on linking.
* Be explicit about routine signatures. If a method accepts a `*%args`,
  but treats some of them specially, list them separately.
* Check out [the styleguide](writing-docs/STYLEGUIDE.md) for further guidance.

## Writing Code Examples

See [EXAMPLES.md](writing-docs/EXAMPLES.md) for detailed information on the options
available when writing code examples in the documentation.

## Documenting types

The POD documentation of types is located in the `doc/Type` directory and
subdirectories of this repository. For example the POD of `X::Bind::Slice`
lives in `doc/Type/X/Bind/Slice.pod6`.

To start contributing fork and checkout the repository, find the document
you want to improve, commit your changes, and create a pull request. Should
questions come up in the process feel free to ask in
[#perl6 IRC channel](https://perl6.org/community/irc).

If the documentation for a type does not exist, create the skeleton of the doc
with the helper tool `util/new-type.p6`. Say you want to create `MyFunnyRole`:

    $ perl6 util/new-type.p6 --kind=role MyFunnyRole

Fill the documentation file `doc/Type/MyFunnyRole.pod6` like this:

    =TITLE role MyFunnyRole

    =SUBTITLE Sentence or half-sentence about what it does

        role MyFunnyRole does OtherRole is SuperClass { ... }

    Longer description here about what this type is, and
    how you can use it.

        # usage example goes here

    =head1 Methods

    =head2 method do-it

        method do-it(Int $how-often --> Nil:D)

    Method description here

        MyFunnyRole.do-it(2);   # OUTPUT: «example output␤»


When documenting a pair of a sub and a method which both do the same thing, the
heading should be `=head2 routine do-it`, and the next thing should be two or
more lines with the signatures. Other allowed words instead of `method` are
`sub`, `trait`, `infix`, `prefix`, `postfix`, `circumfix`, `postcircumfix`,
`term`. If you wish to hide a heading from any index prefix it with the empty
comment `Z<>`.

When providing a code example result or output, use this style:

    # For the result of an expression.
    1 + 2;     # RESULT: «3»
    # For the output.
    say 1 + 3; # OUTPUT: «3␤»
    # For the explanatory comment
    do-work;   # We call do-work sub

## Running tests

Any contributions should pass the `make test` target. This insures basic
integrity of the documentation, and is run automatically by a corresponding
travis build. Even edits made via the GitHub editor should pass this test.

The repo should also pass `make xtest` most of the time - this includes
tests about whitespace and spelling that might be difficult to get right
on an initial commit, and shouldn't be considered to break the build. If
you're contributing a patch or pull request, please make sure this passes.

If you have local modifications and want to insure they pass xtest before
committing, you can use this command to test only modified files:

    TEST_FILES=`git status --porcelain --untracked-files=no | awk '{print $2}'` make xtest

## Writing and Testing Examples

See [Writing and Testing Examples](writing-docs/EXAMPLES.md)

## Testing method completeness

To get a list of methods that are found via introspection but not found in any
pod6 under `doc/Type/`, use `util/list-missing-methods.p6`. It takes a
directory or filepath as argument and limits the listing to the given file or
any pod6-files found. All methods listed in `util/ignored-methods.txt` are
ignored.

## Debug mode

On the right side of the footer you can find [Debug: off]. Click it and reload
the page to activate debug mode. The state of debug mode will be remembered by
`window.sessionStorage` and will not survive a browser restart or opening the
docs in a new tab.

### Invisible index anchors

You can create index entries and invisible anchors with `X<|thing,category>`.
To make them visible activate debug mode.

### Broken links

To check for broken links use debug mode. Any spotted broken link will be
listed under the search input. Please note that some external links may not get
checked depending on your browser settings.

### Heading numbering

Please check if the headings you add are of sound structure. You can use debug mode
to display heading numbers.

## Reporting bugs

Report issues at https://github.com/perl6/doc/issues. You can use the
following labels when tagging tickets:

* site   - presentation issue with the website (e.g. invalid HTML)
* docs   - missing or incorrect documentation (use 'NOTSPECCED' instead, if this is for a feature present in a compiler, but not in the Perl 6 test suite)
    * new - this is a new doc item that requires fresh text
    * update - this is an existing doc item that requires some analysis or editing
* build  - scripts or libraries that generate the site
* search - the search component, either for items that are on the site but not searchable, or for search functionality)

Contributors may also specify one of the following tags.

* LHF    - as in *low hanging fruit*, for a beginner to work on
* big    - a big issue, requires research or consensus

If you would like to contribute documentation or other bug fixes, please use
github's Pull request feature.

## Building the documentation

Assuming that you have already forked and cloned the
[perl6/doc](https://github.com/perl6/doc) repository, one of the first things
you probably want to do is to build the documentation on your local
computer.  To do this you will need:

  - Perl 6 (e.g., the Rakudo Perl 6 implementation)
  - zef (the installer for third party Perl 6 modules)
  - `Pod::To::HTML` (Perl 6 module for converting Pod objects to HTML)
  - [graphviz](http://www.graphviz.org/) (`sudo apt-get install graphviz` on Debian/Ubuntu)
  - [Mojolicious](https://metacpan.org/pod/Mojolicious)
    (optional; a Perl 5 web framework; it allows you to run a web
    app locally to display the docs)
  - [SASS](http://sass-lang.com/) Compiler
  - [highlights](https://github.com/perl6/atom-language-perl6) (optional; requires
    `nodejs`, `npm`, and at least GCC-4.8 on Linux to be installed. Running `make` will set everything up for you.)
    - Debian instructions:
      - Get more modern nodejs than in package manager: `curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -`
      - Run `make init-highlights` to initialize highlights
      - If that still isn't working try running `npm install node-gyp -g` and try running make command again

### Dependency installation

#### Rakudo

You need Perl 6 installed. You can install the Rakudo Perl 6 compiler by
downloading the latest Rakudo Star release from
[rakudo.org/downloads/star/](http://rakudo.org/downloads/star/)

#### Zef

[Zef](https://modules.perl6.org/repo/zef) is a Perl 6 module installer. If you
installed Rakudo Star package, it should already be installed. Feel free to
use any other module installer for the modules needed (see below).

#### Pod::To::HTML

The program that builds the HTML version of the documentation
(`htmlify.p6`) uses `Pod::To::HTML` to convert Pod structures into HTML.
You'll also need `Pod::To::BigPage`. Install these modules like so:

    $ zef install Pod::To::HTML Pod::To::BigPage

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

#### SASS Compiler

To build the styles, you need to have a SASS compiler. You can either install
the `sass` command

    $ sudo apt-get install ruby-sass

or the [CSS::Sass Perl 5 module](https://modules.perl6.org/repo/CSS::Sass)

    $ cpanm -vn CSS::Sass Mojolicious::Plugin::AssetPack

The SASS files are compiled when you run `make html`, or `make sass`, or
start the development webserver (`./app-start`).

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

#### Using Docker to build and view the documentation

You can skip all the above and just build and view documentation with these simple commands (if you have docker already installed):

    $ docker build -t perl6-doc .
    $ docker run -p 3000:3000 -it -v `pwd`:/doc perl6-doc

This will build the documentation for you by default and it will take some time, but for subsequent use you may want to skip build part if nothing has been changed:

    $ docker run -p 3000:3000 -it -v `pwd`:/doc perl6-doc bash -c "perl app.pl daemon"

Now point your web browser to http://localhost:3000 to view the documentation.

Alternatively, you can use make to build and run your container. To build the image:

    $ make docker-image

To build the HTML documentation:

    $ make docker-htmlify

To run the development web server for viewing documentation (on port 3000):

    $ make docker-run

Note that while this requires less typing, some assumptions will be made for you regarding the name
of the resulting image, the port the content is available over, etc. If you want, you can
override these default values.

For instance, if you want the local documentation to be available over port 5001 of the host,
pass the following to make when running:

    $ make docker-run DOCKER_HOST_PORT=5001

Now the documentation will be available on the host at http://localhost:5001. Please see the
Makefile for a list of available options.
