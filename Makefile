.PHONY: test xtest push help test-mine xtest-mine

# Common tests - also run by CI
test test-mine: testlist := t
# Extended tests - should be run by authors before committing
xtest xtest-mine: testlist := t xt

test-mine xtest-mine: TEST_FILES := $(shell git ls-files --modified)
export TEST_FILES

help:
	@echo "Usage: make [test|xtest|push]"
	@echo ""
	@echo "Options:"
	@echo "      test:             run the basic test suite"
	@echo "     xtest:             run all tests"
	@echo " test-mine:             run the basic test suite on files with changes"
	@echo "xtest-mine:             run all tests on files with changes"
	@echo "      push:             run the basic test suite and git push"
	@echo "      prep:             install the prerequisites for running the tests"

# Actually run the tests
test xtest test-mine xtest-mine:
ifeq ("${TEST_JOBS}", "")
	RAKULIB=. prove --ext=rakutest -e raku $(testlist)
else
	RAKULIB=. prove --ext=rakutest -j ${TEST_JOBS} -e raku $(testlist)
endif

push: test
	git pull --rebase && git push

prep:
	zef install --deps-only --exclude="dot" --/test .
