#!/bin/sh

# Anyone working out of the git repo should regularly run 'make xtest'
# on their changes
#
# While util/update-and-test allows a developer to test only those files
# that have changed since the last run, this script picks the last 40
# POD/Markdown/test file changed, uniques them, and runs 'make test' on them.
#
# Running 'make test' on # all the files is *very* slow, this gives developers
#a shortcut to
# verify recent work.


TEST_FILES="$(git log --name-status | awk '/^M.*\.(pod6|md|t)$/ {print $2}' | head -40 | sort -u)" make xtest "$@"
