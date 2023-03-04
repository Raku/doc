# Contributing examples to the documentation

Please follow these guidelines if you are illustrating the
documentation with some example.

## Writing Examples

Please use code blocks to highlight example code; any indented blocks
are considered to be code, but you can specify the `=for code` directive, or a
combination of `=begin code` and `=end code` to better control which
blocks are considered. The POD6 directives also allow you to set
attributes for a block of code.

When using a `=for code` directive or a `=begin code`/`=end code`
combination, the code block does not need to be indented and should not
be for a better aligned result.

## Testing Examples

The file `xt/examples-compilation.t` will test the code from all the
examples. This file is run as part of `make xtest`.

To test specific files (recommended), pass them as options on the command
line to the test file, or set the environment variable TEST_FILES to
a space separated list.

Note that method signatures are also compiled. They have an implied block
added to insure valid compilation.

Care is taken to wrap the sample code in enough boilerplate so that no
runtime code is executed, and that a class is available if needed.

Note: because we are considering each POD code block independently,
there is no guarantee that a partial snippet will itself be compilable.
For this reason, it's fine to use `preamble` (see below) to give each
block enough information to compile. For pedagogical reasons, it's
OK to break what would otherwise be a large block of code into smaller
chunks and discuss each one separately - we still want to do our best
to compile these individual chunks.

## Skipping or finessing tests

While our goal is to test every example of Raku in the repository, some
blocks are not easy to test. Here are some ways you can skip the test or
finesse it.

### Other languages

We're just testing Raku here: to mark as another language, use `:lang`,
and this will avoid testing:

    =begin code :lang<tcl>
    puts "this is not Perl"
    =end code

For plain text use `:lang<text>`

### Allow .WHAT

One of the checks is to dissuade using `.WHAT` in tests; However, in rare
cases that is the explicit point of the test, so you can allow it with ok-test:

    =begin code :ok-test<WHAT>
    say 42.WHAT;
    =end

### Allow dd

`dd` is a rakudo specific routine that isn't part of the specification; examples
shouldn't use it unless they are explicitly trying to show how it works.
You can allow it with ok-test:

    =begin code :ok-test<dd>
    dd 42;
    =end

### Allow .perl

One of the checks is to discourage using `.perl` in tests: the `raku`
method should be used instead.
If needed you can allow the use of the `perl` method with ok-test:

    =begin code :ok-test<perl>
    say {:42a}.perl;
    =end

### Methods

If a code snippet looks like a method declaration, it's automatically
wrapped in additional code so you don't have to specify a body in the docs.
Multi-line method signatures are much harder to detect, so if you have a
method body that spans lines, use the `:method` tag:

    =begin code :method
    method arg (
        Bool $one,
        Bool $two
    )
    =end code

This helps keep the method detection logic in the test code simple.

Conversely, sometimes the method detection is overeager; you can disable it
entirely with `:method<False>`

### Preambles

When writing examples, it's often helpful to refer to things that aren't
defined in that snippet; you don't want to have to have a full working
example in the code.

    =begin code :preamble<no strict;>
    $x = pi;
    =end code

    =begin code :preamble<my $x; sub frob {...};>
    $x = frob();
    =end code

Note that when running the code, it's compiled inside an anonymous class.
The preamble is the first code in this class, so if you're testing the
definition of a complex method signature that requires attributes, you can
declare them using this construct.

### Complicated Examples

Some examples are too complicated to be run using our EVAL trick.
Tag these with `:solo`, and they will be run as a separate standalone
script. This is slower, so only use it on those examples that require
it. Anything using `unit` or `export` is a good candidate. Note that
using this tag means the code is not wrapped as it is for the EVAL path.

### Failures

Some examples fail with compile time exceptions and would interrupt the test
for a file. Use the pod-config option `skip-test` to skip them. When possible,
specify a reason why you have to use this; it should be considered a last
resort, and many examples might be amenable to using one of the
previous annotations.

    =begin code :skip-test<compile time error>
    if 1 "missing a block";
    =end code

### Code Indentation / Formatting

Documentation can be formatted as code using multiple source
styles.

## Indented text

4-space indented text is formatted as a code block. The indent is *not*
part of the displayed code. It's not possible to add any POD6
directives on this style.

## =for code

The following block of text is treated as code. The indentation level
is from the beginning of the line, regardless of how the `=for`
is indented.

## =begin code / =end code

The enclosed text is treated as code. The indentation level is
relative to the indentation of the POD6 directives.

##  Environment Variables

* set `RAKU_DOC_TEST_VERBOSE` to a true value to display verbose messages during test suite run.
* `RAKU_DOC_TEST_FUDGE` fudges `skip-test` code examples as TODO in `xt/examples-compilation.t` test.
