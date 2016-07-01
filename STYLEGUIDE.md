### Structure

##### How to document multiple similar routines

Avoid writing a routine's documentation in the form

    Like [other method] except [...]

even when they're in the same class, because readers might not read the whole
class page, but rather navigate to a specific routine (maybe even out of
context in the /routine/ section of the website) and expect it to tell them how
it works without being sent on a goose chase around the site.

In other words, give each routine documentation a self-contained introduction,
and only link to related/similar routines *below* that introduction, even if
that means duplicating some half-sentences multiple times.

##### Links to docs

Try to avoid absolute URLs.

    L<foo|/routine/foo>

Works well.

If you have to use the full URL in the docs or elsewhere, ensure the
subdomain is `docs` and the protocol is `https://` (as in
`https://docs.perl6.org/blah/blah`). Other variations of the URL will still
work, for convenience, but they all simply redirect to the canonical version,
so it's best to use it from the start.

### Language

##### 'parameter' vs 'argument'

* Argument: what it looks like to the caller
* Parameter: what it looks like to the function

    S06: "In Perl 6 culture, we distinguish the terms parameter and argument; a
    parameter is the formal name that will attach to an incoming argument
    during the course of execution, while an argument is the actual value that
    will be bound to the formal parameter. The process of attaching these
    values (arguments) to their temporary names (parameters) is known as
    binding. (Some C.S. literature uses the terms "formal argument" and "actual
    argument" for these two concepts, but here we try to avoid using the term
    "argument" for formal parameters.)"

##### 'object' vs 'value'

You may use `object` for anything you can call methods on, including value objects and type objects. Consider `instance` for defined objects.

##### Use present tense when talking about Perl 5 features

* Instead of: "In Perl 5 this was used for ..., but in Perl 6 ..."
* Say: "In Perl 5 this is used for ..., but in Perl 6 ..."

##### Don't reference Perl 5 unless in a 5-to-6 document or related document

We are not expecting our users to have to know Perl 5 to learn Perl 6, so this
should not be part of the bulk of the documentation.
