REPO_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

DOCKER_IMAGE_NAME    ?= p6doc
DOCKER_HOST_PORT     ?= 3000
DOCKER_SELINUX_LABEL ?= 0
SELINUX_OPT          := $(shell [ $(DOCKER_SELINUX_LABEL) -eq 1 ] && echo ':Z' || echo '' )

.PHONY: html init-highlights html-nohighlight sparse assets webdev-build \
	bigpage test xtest ctest help run clean-html clean-examples clean-images \
	clean-search clean test-links extract-examples push \
	docker-image docker-htmlify docker-test docker-xtest docker-ctest docker-testall docker-run

html: bigpage htmlify

htmlify: init-highlights assets
	perl6 htmlify.p6 --parallel=1

init-highlights:
	ATOMDIR="./highlights/atom-language-perl6";  \
	if [ -d "$$ATOMDIR" ]; then (cd "$$ATOMDIR" && git pull); \
	else git clone https://github.com/perl6/atom-language-perl6 "$$ATOMDIR"; \
	fi; cd highlights; npm install .

html-nohighlight:
	perl6 htmlify.p6 --no-highlight

sparse:
	perl6 htmlify.p6 --no-highlight --sparse=10

assets:
	./app.pl assets

webdev-build:
	perl6 htmlify.p6 --no-highlight --sparse=200

bigpage:
	pod2onepage --threads=1 -v --source-path=./doc --exclude=404.pod6,/.git > html/perl6.xhtml

# Common tests that are run by travis with every commit
test:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e perl6 t; else prove -e perl6 t; fi

# Extended tests
xtest:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e perl6 xt t; else prove -e perl6 xt t; fi

# Content tests
ctest:
	prove --exec perl6 -r t/tabs.t xt/perl-nbsp.t  xt/trailing-whitespace.t

help:
	@echo "Usage: make [html|html-nohighlight|test|xtest|ctest]"
	@echo ""
	@echo "Options:"
	@echo "   html:             generate the HTML documentation"
	@echo "   html-nohighlight: generate HTML documentation without syntax highlighting"
	@echo "   assets:           generate CSS/JS assets"
	@echo " sparse:             generate HTML documention, but only every 10th file"
	@echo "webdev-build:        generate only a few HTML files (useful for testing website changes)"
	@echo "bigpage:             generate HTML documentation in one large file (html/perl6.xhtml)"
	@echo "init-highlights:     install prereqs for highlights (runs as part of 'make html')"
	@echo "   test:             run the test suite"
	@echo "  xtest:             run the test suite, including extra tests"
	@echo "  ctest:             run the test suite, content tests only"
	@echo "    run:             run the development webserver"
	@echo "docker-image:        build Docker image from Dockerfile"
	@echo "docker-htmlify:      generate the HTML documentation (in container)"
	@echo "docker-test:         run the test suite (in container)"
	@echo "docker-xtest:        run the test suite, including extra tests (in container)"
	@echo "docker-ctest:        run the test suite, content tests only (in container)"
	@echo "docker-testall:      run all tests (in container)"
	@echo "docker-run:          run the development webserver (in container)"

run:
	@echo "Starting local server…"
	morbo -w assets app.pl

docker-image:
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-htmlify: docker-image docker-test
	docker run --rm -v $(REPO_PATH):/perl6/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make html'

docker-test: docker-image
	docker run --rm -v $(REPO_PATH):/perl6/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make test'

docker-xtest: docker-image
	docker run --rm -v $(REPO_PATH):/perl6/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make xtest'

docker-ctest: docker-image
	docker run --rm -v $(REPO_PATH):/perl6/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make ctest'

docker-testall: docker-test docker-xtest docker-ctest

docker-run: docker-image
	docker run --rm -p $(DOCKER_HOST_PORT):3000 -v $(REPO_PATH):/perl6/doc/$(SELINUX_OPT) \
		$(DOCKER_IMAGE_NAME) /bin/bash -c './app-start' &

clean-html:
	rm -rf html/*.html html/.*.html \
		html/language/ \
		html/op/ \
		html/programs/ \
		html/routine/ \
		html/syntax/ \
		html/type/ \
		$(NULL)

clean-examples:
	rm -fr examples/*

clean-images:
	rm -f html/images/type-graph*

clean-search:
	rm -f html/js/search.js

clean: clean-html clean-images clean-search clean-examples

test-links: links.txt
	./util/test-links.sh

extract-examples:
	./util/extract-examples.p6 --source-path=./doc/ --prefix=./examples/

push: test
	git pull --rebase && git push
