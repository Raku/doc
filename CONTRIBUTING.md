Your patches to perl6/doc are very welcome.

They are even more welcome if you stick to our style and formatting
guidelines.

If you have any questions regarding contributing to this project, please ask
in the [#perl6 IRC channel](http://perl6.org/community/irc).

## General principles

* Please use the present tense.
* Link to external resources (like Wikipedia) for topics that are not
  directly related to Perl 6 (like the math that our routines implement)
* Duplicate small pieces of information rather than rely on linking
* Be explicit about routine signatures. If a method accepts a `*%args`,
  but treats some of them specially, list them separately.

## Documenting types

Types should be documented like this (the tool `util/new-type.p6` can create
the skeleton for you):

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
