### Conventions

1. It must be valid Raku pod
2. The first non-comment or non-empty line must be:

        =begin pod # optionally followed by :key<value> %config pairs

3. The second non-comment or non-empty line must be:

        =TITLE ...text...

4. An optional (but usually desired) subtitle must be the third non-comment or non-empty line:

        =SUBTITLE ...text...

5. The last non-comment or non-empty line must be:

        =end pod

See [TESTING.md](TESTING.md) for how to programmatically verify these and other requirements.

### Valid example:

```
# this is a valid, non-pod comment
=begin pod :my-link<foo> # another comment
=TITLE Working with Raku pod
=SUBTITLE Alice in Wonderland
# ... more valid pod and text
=comment a pod comment # a valid comment
=end pod
```

### Invalid example:

```
=comment a pod comment # this is not a valid comment in this position
=begin pod :my-link<foo> # another comment
=TITLE Working with Raku pod
=SUBTITLE Alice in Wonderland
# ... more valid pod and text
=end pod
```
