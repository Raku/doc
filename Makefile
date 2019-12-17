REPO_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PATH := $(PATH)
DOCKER_IMAGE_NAME    ?= p6doc
DOCKER_HOST_PORT     ?= 3000
DOCKER_SELINUX_LABEL ?= 0
COLON_Z              := :Z
SELINUX_OPT          := $(shell [ $(DOCKER_SELINUX_LABEL) -eq 1 ] && echo "$(COLON_Z)" || echo '' )
# dependencies for a new doc/Language build:
LANG_POD6_SOURCE     := $(wildcard doc/Language/*.pod6)
# Managing of the language index page
USE_CATEGORIES := True

.PHONY: html init-highlights html-nohighlight sparse assets webdev-build \
	bigpage test xtest ctest help run clean-html clean-images \
	clean-search clean test-links push \
        gen-pod6-source clean-build \
	docker-image docker-test docker-xtest docker-ctest docker-testall docker-run

html: gen-pod6-source bigpage

init-highlights:
	ATOMDIR="./highlights/atom-language-raku";  \
	if [ -d "$$ATOMDIR" ]; then (cd "$$ATOMDIR" && git pull); \
	else git clone https://github.com/raku/atom-language-raku "$$ATOMDIR"; \
	fi; cd highlights; npm install .; npm rebuild

assets:
	./app.pl assets

for-documentable: init-highlights assets

bigpage: gen-pod6-source
	pod2onepage --html -v --source-path=./build --exclude=404.pod6 > html/raku.html

epub: bigpage
	pandoc html/raku.html -o raku.epub

# Common tests that are run by travis with every commit
test:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e raku t; else prove -e raku t; fi

# Extended tests
xtest:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e raku t xt; else prove -e raku t xt; fi

# Content tests
ctest:
	prove --exec raku -r t/07-tabs.t xt/perl-nbsp.t  xt/trailing-whitespace.t

help:
	@echo "Usage: make [html|html-nohighlight|test|xtest|ctest]"
	@echo ""
	@echo "Options:"
	@echo "   html:             generate the HTML documentation"
	@echo "   html-nohighlight: generate HTML documentation without syntax highlighting"
	@echo "   assets:           generate CSS/JS assets"
	@echo " sparse:             generate HTML documentation, but only every 10th file"
	@echo "webdev-build:        generate only a few HTML files (useful for testing website changes)"
	@echo "bigpage:             generate HTML documentation in one large file (html/raku.html)"
	@echo "init-highlights:     install prereqs for highlights (runs as part of 'make html')"
	@echo "   test:             run the test suite"
	@echo "  xtest:             run the test suite, including extra tests"
	@echo "  ctest:             run the test suite, content tests only"
	@echo "    run:             run the development webserver"
	@echo "docker-image:        build Docker image from Dockerfile"

	@echo "docker-test:         run the test suite (in container)"
	@echo "docker-xtest:        run the test suite, including extra tests (in container)"
	@echo "docker-ctest:        run the test suite, content tests only (in container)"
	@echo "docker-testall:      run all tests (in container)"
	@echo "docker-run:          run the development webserver (in container)"

start: run

run:
	@echo "Starting local server…"
	./app-start

docker-image:
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-test: docker-image
	docker run --rm -it -v $(REPO_PATH):/Raku/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make test'

docker-xtest: docker-image
	docker run --rm -it -v $(REPO_PATH):/Raku/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make xtest'

docker-ctest: docker-image
	docker run --rm -it -v $(REPO_PATH):/Raku/doc/$(SELINUX_OPT) $(DOCKER_IMAGE_NAME) \
		/bin/bash -c 'make ctest'

docker-testall: docker-test docker-xtest docker-ctest

docker-run: docker-image
	docker run --rm -it -p $(DOCKER_HOST_PORT):3000 -v $(REPO_PATH):/Raku/doc/$(SELINUX_OPT) \
		$(DOCKER_IMAGE_NAME) /bin/bash -c './app-start' &

clean-html:
	rm -rf html/*.html html/.*.html \
		html/.html \
		html/language/ \
		html/op/ \
		html/programs/ \
		html/routine/ \
		html/syntax/ \
		html/type/ \
		$(NULL)

clean-images:
	rm -f html/images/type-graph*

clean-search:
	rm -f html/js/search.js

clean-build:
	find build -name "*.pod6" -exec rm -f {} \;

remove-build:
	rm -rf build

clean: clean-html clean-images clean-search clean-build

distclean: clean remove-build


test-links: links.txt
	./util/test-links.sh

push: test
	git pull --rebase && git push
