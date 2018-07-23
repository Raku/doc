A new (or existing) pod6 document currently must adhere to the following conventions:

1. it must be valid Perl 6 pod
2. the first non-comment or non-empty line must be:

        =begin pod # optionally followed by :key<value> %config pairs
        
3. the second non-comment or non-empty line must be:

        =TITLE ...text...
        
4. an optional (but usually desired) subtitle must be the third non-comment or non-empty line:

        =SUBTITLE ...text...
        
5. the last non-comment or non-empty line must be:

        =end pod
