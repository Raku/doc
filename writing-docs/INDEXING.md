# Search indexing rules

### Synopsis

A term or a location in a rakudoc document can be indexed so that it is
possible to create a named reference pointing to it. This can be used
to generate a reference in the rendered version of the documentation or
implement search function on the website hosting the rendered documentation.

### Format

An index item is created using the Pod formatting code `X` in these formats:

    X<text|category,item>
    X<text|category1,item1;category2,item2;...>
    X<|category,item>

For the first example, the `text` text is rendered,
an item with text `item` under the category `category` is added to the index.

Note it also creates a page anchor in the current website implementation.

The second example demonstrates how the `;` separator can be used to
index more than a single item, and the third item has no text rendered,
but an invisible anchor (e.g. for the HTML version) is created that can be used
to navigate to via URL.

Valid examples are:

    X<|Syntax,does>
    X<|Language,\ (container binding)>
    X<Subroutines|Syntax,sub>
    X<|Variables,$*PID>
    X<Automatic signatures|Variables,@_;Variables,%_>
    X<Typing|Language,typed array;Syntax,[ ] (typed array)>
    X<Attributes|Language,Attribute;Other languages,Property;Other languages,Member;Other languages,Slot>

### Categories

To avoid cluttering of index item categories, only 28 categories can be specified,
so when indexing new items be sure to use one of:

* `Types` (reference of Raku types)
* `Modules` (built-in modules in Raku)
* `Subroutines` (reference of Raku subroutines)
* `Methods`(reference of Raku methods)
* `Terms` (reference of Raku terms)
* `Adverbs` (reference of Raku adverbs)
* `Traits` (reference of Raku traits)
* `Phasers` (reference of Raku phasers)
* `Asynchronous phasers` (reference of Raku asynchronous phasers)
* `Pragmas` (reference of Raku pragmas)
* `Variables` (reference of Raku special variables)
* `Control flow` (terms related to control flow)
* `Regexes` (terms related to regexes)
* `Operators` (cases of operators not fitting for other operator categories, for example operators like `s///`, hyper, method call operators etc.)
* `Listop operators` (listop ops)
* `Infix operators` (infix ops)
* `Metaoperators` (meta ops)
* `Postfix operators` (postfix ops)
* `Prefix operators` (prefix ops)
* `Circumfix operators` (circumfix ops)
* `Postcircumfix operators` (postcircumfix ops)
* `Tutorial` (indexing explanation of some item in a tutorial-like manner rather than pure reference)
* `Other languages` (terms from other languages and migration guides)
* `Syntax` (indexing various language syntax constructs not fitting into other categories (syntax))
* `Language` (indexing reference-like explanation of various language concepts (semantics), for example, `hash slice` or `Unquoting`)
* `Programs` (legacy, program writing-related topics) # to be decided
* `Reference` (indexing various concepts and names not directly coming from Raku or other languages, for example, `opcode` or `MoarVM`)

If you see an item miscategorized, please give it some love or open a ticket if you are not sure where
it fits best.

Other than explicit creation, headers (`=head` elements of Pod) of certain format get an anchor automatically,
say `=head routine sin` creates an index item categorized as `Subroutines` automatically.

### Testing

There is a test checking basic syntax of the references in the documentation
in author tests, so the suite passing means the references are at least well-formatted.
