## Contributing

Your patches to perl6/doc are very welcome.

This document describes how to get started and helps to provide documentation
that adheres to the common style and formatting guidelines.

If you have any questions regarding contributing to this project, please ask
in the [#perl6 IRC channel](http://perl6.org/community/irc).

## General principles

* Please use the present tense, and active voice.
* Link to external resources (like Wikipedia) for topics that are not
  directly related to Perl 6 (like the math that our routines implement)
* Duplicate small pieces of information rather than rely on linking
* Be explicit about routine signatures. If a method accepts a `*%args`,
  but treats some of them specially, list them separately.

## Documenting types

The POD documentation of types is located in the `lib/Type` directory and
subdirectories of this repository. For example the POD of `X::Bind::Slice`
lives in `lib/Type/X/Bind/Slice.pod`.

To start contributing fork and checkout the repository, find the document
you want to improve, commit your changes, and create a pull request. Should
questions come up in the process feel free to ask in
[#perl6 IRC channel](http://perl6.org/community/irc).

If the documentation for a type does not exist create the skeleton of the doc
with the helper tool `util/new-type.p6`. Say you want to create `MyFunnyRole`:

    $ perl6 util/new-type.p6 MyFunnyRole

Fill the documentation file `lib/Type/MyFunnyRole.pod` like this:

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


When documenting a pair of a sub and a method which both do the same thing,
the heading should be `=head2 routine do-it`, and the next thing should be two
or more lines with the signatures. Other allowed words instead of `method`
are `sub`, `trait`, `infix`, `prefix`, `postfix`, `circumfix`,
`postcircumfix`, `term`.

## Building the documentation

Assuming that you have already forked and cloned the
[perl6/doc](http://github.com/perl6/doc) repository, one of the first things
you probably want to do is to build the documentation on your local
computer.  To do this you will need:

  - Rakudo (the Rakudo Perl 6 implementation)
  - Panda (the installer for third party Perl 6 modules)
  - `Pod::To::HTML` (Perl 6 module for converting Pod objects to HTML)
  - Mojolicious (optional; a Perl 5 web framework; it allows you to run a web
    app locally to display the docs)
  - pygmentize (optional; a program to add syntax highlighting to code
    examples)
  - `Inline::Python` (optional; run Python code from within Perl 6,
    necessary for faster execution of pygmentize)

### Dependency installation

#### Rakudo

Install Rakudo via [rakudobrew](http://github.com/tadzik/rakudobrew).

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

    $ rakudobrew build-panda

Now the `panda` command should be available.

#### Pod::To::HTML

The program which builds the HTML version of the documentation
(`htmlify.p6`) uses `Pod::To::HTML` to convert Pod structures into HTML.
Install `Pod::To::HTML` like so:

    $ panda install Pod::To::HTML

#### Mojolicious

This is a Perl 5 web framework which is used to run the web application
which renders and displays the HTML documentation in a web browser.  It is
written in Perl 5, so assuming that you use
[`cpanm`](http://search.cpan.org/~miyagawa/App-cpanminus-1.7027/lib/App/cpanminus.pm),
install this now:

    $ cpanm Mojolicious

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
using syntax highlighting.  It can simply be installed via `panda`

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
