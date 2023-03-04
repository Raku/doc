# How to help

Raku is not a small language, and documenting it and maintaining that
documentation takes a lot of effort. Any help is appreciated.

Here are some ways to contribute:

 * Add missing documentation for classes, roles, methods or operators. _Except
   superclasses & roles, those are already included in the website generated from this repository._
 * Add usage examples to existing documentation.
 * Proofread and correct the documentation.
 * Tell us about missing documentation by [opening issues](https://github.com/Raku/doc/issues)
 * Do a `git grep TODO` in this repository, and replace the TODO items by
   actual documentation.

[Issues page](https://github.com/Raku/doc/issues) has a list of current issues and
documentation parts that are known to be missing
and [the CONTRIBUTING document](CONTRIBUTING.md)
explains briefly how to get started contributing documentation.

# Other docs

For specific topics, please see:
   * [CREATING-NEW-DOCS.md]
   * [EXAMPLES.md]
   * [INDEXING.md]
   * [STYLEGUIDE.md]

# Pull Requests

The preferred mechanism for submitting content is [pull requests](https://github.com/Raku/doc/pulls).

When submitting a PR, please ensure that you've run `make xtest` for any modified files. See [Testing.md]
for more details.
