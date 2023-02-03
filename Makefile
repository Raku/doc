.PHONY: test xtest ctest push help

help:
	@echo "Usage: make [test|xtest|ctest|push]"
	@echo ""
	@echo "Options:"
	@echo "   test:             run the basic test suite"
	@echo "  xtest:             run all tests"
	@echo "  ctest:             run minimal tests"
	@echo "   push:             run the basic test suite and git push"

# Common tests that are run by travis with every commit
test:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e raku t; else prove -e raku t; fi

# Extended tests
xtest:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e raku t xt; else prove -e raku t xt; fi

# Content tests
ctest:
	prove --exec raku -r t/05-tabs.t xt/perl-nbsp.t  xt/trailing-whitespace.t

push: test
	git pull --rebase && git push
