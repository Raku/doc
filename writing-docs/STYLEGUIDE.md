# Style guide

Please follow these style rules when contributing to the documentation

## Text

Please follow these rules when writing the text itself:

* Avoid trailing whitespace in every line, including examples.
* Use always space, never tabs.
* Configure your editor for auto-flowing (or
hard-wrapping) line length at 72 whenever possible.

When writing new text, try to be consistent with the rest of the
docs. If it happens that there's no consistency and this style guide
does not give a recommendation, consult
[Wikipedia's Manual of Style](https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style)
and see if the issue is covered there. Typically, style decisions that
work for Wikipedia can be safely used for writing Perl 6 documentation.

## Structure

### How to document multiple similar routines

Avoid writing a routine's documentation in the form

    Like [other method] except [...]

even when they're in the same class, because readers might not read
the whole class page, but rather navigate to a specific routine (maybe
even out of context in the /routine/ section of the website) and
expect it to tell them how it works without being sent on a goose
chase around the site.

In other words, give each routine documentation a self-contained
introduction, and only link to related/similar routines *below* that
introduction, even if that means duplicating some half-sentences
multiple times.

### Links to docs

Try to avoid absolute URLs.

    L<foo|/routine/foo>

Works well instead.

If you have to use the full URL in the docs or elsewhere, ensure the
subdomain is `docs` and the protocol is `https://` (as in
`https://docs.perl6.org/blah/blah`). Other variations of the URL will
still work, for convenience, but they all simply redirect to the
canonical version, so it's best to use it from the start.

## Language

### Unambiguous is better than short

When you have to choose between two sentence structures, opt for the
unambiguous.

```
my %hash = hash;
my @array = <1 2 3>
```

In this case, `this code initializes a hash` is short, but
ambiguous. Opt for `The first line of this example initializes an
empty hash`.

Try to avoid abbreviations. For example, “RHS” is short, but
“right-hand side” is much clearer for beginners.

In general, try to put yourself in the shoes of someone with no
previous exposition to the language (or computer science
altogether). Although it might seem obvious to
you that only the first line can in fact initialize a hash, the
documentation is targeted at people with no previous exposition to the
language.

### 'say' vs 'put'

While there is no hard and fast rule about which of these routines to use
in a given situation, please try to follow these guidelines.

When generating output in examples intended to be read by a user, use 'say'.
Additionally, add a comment showing the intended output, e.g.:

    say 3.^name; #OUTPUT: «Int␤»

For examples where a particular format is required, or exact data is expected
(e.g. for something sent over a network connection), prefer 'put'.

### 'parameter' vs 'argument'

* Argument: what it looks like to the caller
* Parameter: what it looks like to the function

    S06: "In Perl 6 culture, we distinguish the terms parameter and argument; a
    parameter is the formal name that will attach to an incoming argument
    during the course of execution, while an argument is the actual value that
    will be bound to the formal parameter. The process of attaching these
    values (arguments) to their temporary names (parameters) is known as
    binding. (Some C.S. literature uses the terms "formal argument" and "actual
    argument" for these two concepts, but here we try to avoid using the term
    "argument" for formal parameters.)"

### 'object' vs 'value'

You may use `object` for anything you can call methods on, including
value objects and type objects. Consider `instance` for defined
objects.

### 'filehandle' vs 'file-handle', 'file handle' and other dashed or space-separated constructs

Be consistent when using this kind of constructs. Generally, the form
with no dash or space is preferred.  As of
[issue 2015](https://github.com/perl6/doc/issues/2015) the term must
be written without spaces between words. When in doubt, search for the
term in the documentation and stick to the form that is used the most
(and create an issue to change the form that is not).

### Use present tense when talking about Perl 5 features

Perl 5 is still an active language, therefore instead of "In Perl 5
this was used for ..., but in Perl 6 ..."  use a form like "In Perl 5
this is used for ..., but in Perl 6 ..."  ('was' has been made a
present 'is').

### Prefer clear and readable variable names

While Perl 6 allows all kinds of fancy characters in identifiers,
stick to easily understandable names:

    my $sub; # GOOD
    my $ßub; # BAD; Is it a twigil? How do I type this? HELP!

If you want to add some fancy characters, please stick to
[well-known characters from our Unicode set](https://docs.perl6.org/language/unicode_ascii).

### Prefer non-ASCII syntax in examples

    my @infinite-sequence = 1, 3 … ∞     # GOOD
    my @infinite-sequence = 1, 3 ... Inf # OK, but rather not
    <a b c >  ⊖  <c d e> # Good
    <a b c > (^) <c d e> # OK, but don't do that

All operators have an ASCII equivalent, but they are more verbose and
do not correspond exactly to the mathematical operator or constant
they often represent. Please use that syntax whenever possible.

### Try to express intent, rather than just demonstrating the syntax

    my @l = lazy 0..5;                             # Correct, but BAD
    my @too-long-list = lazy 0..100000000          # GOOD
    my @powers-of-eleven = lazy 1, 11, 121 … 10¹⁰⁰ # EVEN BETTER

In the first case, the syntax is totally correct. But a list with 5
elements need not be made lazy. The second is better, because it does
show the intent: work with long lists that need not be filling up
memory until they are needed. However, the last one is better because
it includes a real use case: in the progression, Perl 6 does not need
to actually compute its terms until they are really needed.

## Perl 5 and Perl 6

Style guidelines related to Perl *.

### Don't reference Perl 5 unless in a 5-to-6 document or related document

We are not expecting our users to have to know Perl 5 to learn Perl 6,
so this should not be part of the bulk of the documentation.

### Use non-breaking spaces when dealing with Perl version numbers

To avoid the version number to be wrapped on a separate line from the
'Perl' term, use a
[non-breaking space (NBSP)](https://en.wikipedia.org/wiki/Non-breaking_space),
that is coded as Unicode character U+00A0.

To convert all Perl names to this style in `SOME-FILE`, you can use
this one liner:

    perl -C -pi -e 's/Perl (6|5)/Perl\x{A0}$1/g'  SOME-FILE

## Domain

What should be documented? The primary goal of the programmatic
documentation is to cover items that are part of the specification (the
roast test suite)

* If something is visible to users of Perl 6 and is in roast: document it.
* If something is visible to users of Perl 6 and is not in roast:
  check with the dev team (#perl6-dev on freenode) - This might need
  have a test added (and therefore docs), or it might need to be
  hidden so users cannot see it. In general, documentation of
  implementation-specific features should be avoided; however, if
  eventually the feature is added to the documentation, always specify
  clearly its implementation-specific nature and where possible show
  the first and latest version the documented feature is available.

Future considerations along this line include: documenting things that
are rakudo specific (like "dd"), and documenting which versions of the
spec items are available in.

## Use of HTML

Generally, Pod 6 should be more than enough for any
documentation. However, if you need to embed HTML into the
documentation after thinking it twice, bear in mind that we support
the current and previous major releases of Chrome, Firefox, Internet
Explorer (Edge), and Safari. Please test layout changes.  Lacking
actual browsers to test in, you can use
[browsershots.org](http://browsershots.org) or
[browserstack.com](http://browserstack.com). Ensure the layout looks
OK on mobile.

### Viewport size

If you change the layout please check different screen sizes. Debug
mode will display the viewport size in the bottom left corner.
