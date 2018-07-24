### A new (or existing) pod6 document currently must adhere to the following conventions:

1. it must be valid Perl 6 pod
2. the first non-comment or non-empty line must be:

        =begin pod # optionally followed by :key<value> %config pairs

3. the second non-comment or non-empty line must be:

        =TITLE ...text...

4. an optional (but usually desired) subtitle must be the third non-comment or non-empty line:

        =SUBTITLE ...text...

5. the last non-comment or non-empty line must be:

        =end pod

### Valid example:

```
# this is a valid, non-pod comment
=begin pod :my-link<foo> # another comment
=TITLE Working with Perl 6 pod
=SUBTITLE Alice in Wonderland
# ... more valid pod and text
=comment a pod comment # a valid comment
=end pod
# vi or emacs info
```

### Invalid example:

```
=comment a pod comment # this is not a valid comment in this position
=begin pod :my-link<foo> # another comment
=TITLE Working with Perl 6 pod
=SUBTITLE Alice in Wonderland
# ... more valid pod and text
=end pod
# vi or emacs info
```
