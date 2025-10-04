# This script will run make xtest on any files in the repository that have not yet been committed
# use before 'git commit' to ensure your commit doesn't require correction.

export TEST_FILES=`git status --porcelain | egrep '^( M|A )' | awk '{print $2}'`

[ "$TEST_FILES" = "" ] && echo "nothing to test"
[ "$TEST_FILES" != "" ] && RAKULIB=. make xtest
