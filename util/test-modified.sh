export TEST_FILES=`git status --porcelain | grep ' M' | awk '{print $2}'`

[ "$TEST_FILES" = "" ] && echo "nothing to test"
[ "$TEST_FILES" != "" ] && make xtest
