#!/bin/sh

# Test only the most recent commits for xtest issues
# (much faster than running the whole suite)


TEST_FILES=$(git llog | egrep '^M.*\.(pod6|md)$' | head -40 | sort -u | awk '{print $2}' | tr '\n' ' ' | sed 's/ $//') make xtest
