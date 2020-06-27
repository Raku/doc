#!/bin/sh

# Test only the most recent commits for xtest issues
# (much faster than running the whole suite)


TEST_FILES="$(git log --name-status | awk '/^M.*\.(pod6|md)$/ {print $2}' | head -40 | sort -u)" make xtest "$@"
