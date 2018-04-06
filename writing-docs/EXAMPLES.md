# Contributing examples to the documentation

Please follow these guidelines if you are illustrating the documentation with some example.

## Writing Examples

Please use code blocks to highlight example code; any indented blocks
are considered to be code, but you can use the `=for code` directive, or a
combination of `=begin code` and `=end code` to better control which
blocks are considered.

## Testing Examples

The file `xt/examples-compilation.t` will test the code from all the
examples. This file is run as part of `make xtest`.

Note that method signatures are also compiled. They have an implied block
added to insure valid compilation.

Care is taken to wrap the sample code in enough boilerplate so that no
runtime code is executed, and that a class is available if needed.

## Skipping or finessing tests

While our goal is to test every example of Perl 6 in the repository, some
blocks are not easy to test. Here are some ways you can skip the test or
finesse it.

### Other languages

We're just testing Perl 6 here: to skip another language, use `:lang`

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
shouldn't use it unless they are explicitly trying to show how dd works.
You can allow it with ok-test:

    =begin code :ok-test<dd>
        dd 42;
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

### Failures

Some examples fail with compile time exceptions and would interrupt the test
for a file. Use the pod-config option `skip-test` to skip them. When possible,
specify a reason why you have to use this; it should be considered a last
resort, and many examples might be amenable to using one of the previous annotations.

    =begin code :skip-test<compile time error>
        if 1 "missing a block";
    =end code
