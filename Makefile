.PHONY: test xtest push help

# Common tests - also run by CI
test: testlist := t
# Extended tests - should be run by authors before committing
xtest: testlist := t xt

help:
	@echo "Usage: make [test|xtest|push]"
	@echo ""
	@echo "Options:"
	@echo "   test:             run the basic test suite"
	@echo "  xtest:             run all tests"
	@echo "   push:             run the basic test suite and git push"

# Actually run the tests
test xtest:
ifeq ("${TEST_JOBS}", "")
	RAKULIB=lib prove --ext=rakutest -e raku $(testlist)
else
	RAKULIB=lib prove --ext=rakutest -j ${TEST_JOBS} -e raku $(testlist)
endif

push: test
	git pull --rebase && git push
