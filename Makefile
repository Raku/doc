.PHONY: test xtest push help

help:
	@echo "Usage: make [test|xtest|push]"
	@echo ""
	@echo "Options:"
	@echo "   test:             run the basic test suite"
	@echo "  xtest:             run all tests"
	@echo "   push:             run the basic test suite and git push"

# Common tests - also run by CI
test:
	if [ "${TEST_JOBS}" != "" ]; then prove --ext=rakutest -j ${TEST_JOBS} -e raku t; else prove --ext=rakutest -e raku t; fi

# Extended tests - should be run by authors before committing
xtest:
	if [ "${TEST_JOBS}" != "" ]; then prove --ext=rakutest -j ${TEST_JOBS} -e raku t xt; else prove --ext=rakutest -e raku t xt; fi

push: test
	git pull --rebase && git push
