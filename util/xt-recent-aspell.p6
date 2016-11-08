#!/bin/sh

# Test only the most recent commits for spelling issues.
# (much faster than running the whole xt/aspell.t test)

perl6 xt/aspell.t $(git llog | egrep '^M.*\.(pod6|md)$' | head -40 | sort -u | awk '{print $2}')
