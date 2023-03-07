# Contributing

Your patches to `Raku/doc` are very welcome, and if you want to
help,
[please read this guide](https://github.com/Raku/doc/wiki) as
well as the detailed instructions below.

This document describes how to get started and helps to provide documentation
that adheres to the common style and formatting guidelines.

Your contributions here will be credited in the next Rakudo release
announcement. Your name from the commit log will be used. If you'd like to be
credited under a different name, please add it to the local [CREDITS](CREDITS)
file (or ask someone to do it for you until you have commit privileges).

If you have any questions regarding contributing to this project, please ask
in the [#raku IRC channel](https://raku.org/community/irc).

# TABLE OF CONTENTS
- [General principles](#general-principles)
- [Writing code examples](#writing-code-examples)
- [Indexing content](#indexing-content)
- [Adding a new Language document](#adding-a-new-language-document)
- [Documenting types](#documenting-types)
- [Writing and Testing Examples](#writing-and-testing-examples)
- [Debug mode](#debug-mode)
    - [Invisible index anchors](#invisible-index-anchors)
    - [Viewport size](#viewport-size)
    - [Broken links](#broken-links)
    - [Heading numbering](#heading-numbering)
- [Reporting bugs](#reporting-bugs)
- [Contributing pull requests](#contributing-pull-requests)
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

* Please use the present tense unless writing about history or upcoming events or planned features
* Prefer [active voice](https://en.wikipedia.org/wiki/Active_voice) to the [passive voice](https://en.wikipedia.org/Passive_voice#In_English) with "by": "this is used by crafty programmers" → "crafty programmers use this"
* Link to external resources (like Wikipedia) for topics that are not
  directly related to Raku (like the math that our routines implement).
* Duplicate small pieces of information rather than rely on linking.
* Be explicit about routine signatures. If a method accepts an `*%args`,
  but treats some of them specially, list them separately.
* Check out [the styleguide](writing-docs/STYLEGUIDE.md) for further guidance.

## Documenting versions

* If you are adding a recently introduced feature, please indicate in a note
  which version it was introduced in.
* If you change an example to use the new feature, leave the old
  example if it's still working, at least while it's not obsolete, for people
  who have not upgraded yet, clarifying in the text around it the versions it
  will run with.

## Writing Code Examples

See [EXAMPLES.md](writing-docs/EXAMPLES.md) for detailed information on the options
available when writing code examples in the documentation.

## Indexing content

See [INDEXING.md](writing-docs/INDEXING.md) for detailed information on how
indexing of terms and locations in the documentation works.

## Adding a new Language document

We suggest you discuss proposing a new Language document on the #raku
channel and/or the [issues for this repository](https://github.com/Raku/doc/issues)
before you proceed further. After you get consensus on a title, subtitle,
section, and filename, you can add the document by following these steps:

+ create a **filename.pod6** file in the **doc/Language** directory and
  ensure it adheres to the conventions in
  [CREATING-NEW-DOCS.md](writing-docs/CREATING-NEW-DOCS.md).

## Documenting types

The Pod6 documentation of types is located in the `doc/Type` directory and
subdirectories of this repository. For example the Pod6 file of `X::Bind::Slice`
lives in `doc/Type/X/Bind/Slice.pod6`.

To start contributing, fork and checkout the repository, find the document
you want to improve, commit your changes, and create a pull request. Should
questions come up in the process feel free to ask in
[#raku IRC channel](https://raku.org/community/irc).

If the documentation for a type does not exist, create the skeleton of the doc
with the helper tool `util/new-type.raku`. Say you want to create `MyFunnyRole`:

    $ raku util/new-type.raku --kind=role MyFunnyRole

Fill the documentation file `doc/Type/MyFunnyRole.pod6` like this:

```perl6
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
```

When documenting a pair of a sub and a method with the same functionality, the
heading should be `=head2 routine do-it`, and the next thing should be two or
more lines with the signatures. Other allowed words instead of `method` are
`sub`, `trait`, `infix`, `prefix`, `postfix`, `circumfix`, `postcircumfix`,
`term`. If you wish to hide a heading from any index, prefix it with the empty
comment `Z<>`.

When providing a code example result or output, use this style:

```perl6
# For the result of an expression.
1 + 2;     # RESULT: «3»
# For the output.
say 1 + 3; # OUTPUT: «3␤»
# For the explanatory comment
do-work;   # We call do-work sub
```

## Running tests

Any contributions should pass the `make test` target. This insures basic
integrity of the documentation, and is run automatically by a corresponding
travis build. Even edits made via the GitHub editor should pass this test.

The repo should also pass `make xtest` most of the time - this includes
tests about whitespace and spelling that might be difficult to get right
on an initial commit, and shouldn't be considered to break the build. However,
if you're contributing a patch or pull request, this must pass.

If you have local modifications and want to insure they pass xtest before
committing, you can use this command to test only modified files:

    TEST_FILES=`git status --porcelain --untracked-files=no | awk '{print $2}'` make xtest

## Writing and Testing Examples

See [Writing and Testing Examples](writing-docs/EXAMPLES.md)

## Debug mode

On the right side of the footer you can find [Debug: off]. Click it and reload
the page to activate debug mode. The state of debug mode will be remembered by
`window.sessionStorage` and will not survive a browser restart or opening the
docs in a new tab.

### Broken links

To check for broken links use debug mode. Any spotted broken link will be
listed under the search input. Please note that some external links may not get
checked depending on your browser settings.

### Heading numbering

Please check if the headings you add are well structured. You can use [debug mode](#debug-mode)
to display heading numbers.

## Reporting bugs

Report issues with the content on [github](https://github.com/Raku/doc/issues).
This includes missing or incorrect documentation, as well as information about
versioning (e.g. "method foo" only available in raku v6.d).

For issues with the website functionality (as opposed to the content), for
examples issues with search,
please report on [doc-website](https://github.com/Raku/doc-website/issues).

## Contributing pull requests

If you would like to contribute documentation or other bug fixes, please use
[GitHub's pull requests (PRs)](https://github.com/Raku/doc/pulls). For a complete
recipe for a new PR contributor, check [this PR guide](https://github.com/tbrowder/tidbits/blob/master/Contributing-PRs.md).

### Dependency installation

#### Raku

See [rakudo.org](https://rakudo.org/downloads) for Raku installation information.

#### Zef

To install any prerequisites for this module, use:

    $ zef install --deps-only .

See [zef](https://github.com/ugexe/zef) for any questions on zef.

### Test the documentation

The [Makefile] has a lot of targets to help with testing the documentation
Use this command to see them:

    $ make help
