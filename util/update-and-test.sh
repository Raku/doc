#!/bin/bash

# Get the old and new commit IDs

OLD=`git rev-parse HEAD`
git pull --rebase
NEW=`git rev-parse HEAD`

if [ "x$OLD" == "x$NEW" ]; then
    echo "No changes to test.";
else
    # Test only those files that have changed.
    TEST_FILES=$(git diff --name-only $OLD..$NEW | xargs) make xtest
fi
