REPO_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PATH := $(PATH)
DOCKER_IMAGE_NAME    ?= p6doc
DOCKER_HOST_PORT     ?= 3000
DOCKER_SELINUX_LABEL ?= 0
ifeq ($(DOCKER_SELINUX_LABEL),1)
SELINUX_OPT          := :Z
else
SELINUX_OPT          :=
endif

.PHONY: html init-highlights assets \
	test xtest ctest help run clean-html clean-images \
	clean-search clean test-links push \
	clean-cache \
	docker-image docker-test docker-xtest docker-ctest docker-testall docker-run

help:
	@echo "Usage: make [html|test|xtest|ctest]"
	@echo ""
	@echo "Options:"
	@echo "   html:             generate the HTML documentation"
	@echo "   assets:           generate CSS/JS assets"
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

html: for-documentable
	documentable start -a -v --highlight

update-html:
	documentable update

init-highlights highlights/package-lock.json:
	ATOMDIR="./highlights/atom-language-perl6";  \
	if [ -d "$$ATOMDIR" ]; then (cd "$$ATOMDIR" && git pull); \
	else git clone https://github.com/perl6/atom-language-perl6 "$$ATOMDIR"; \
	fi; cd highlights; npm install .; npm rebuild

assets assets/assetpack.db:
	./app.pl assets

for-documentable: highlights/package-lock.json assets/assetpack.db

# Common tests that are run by travis with every commit
test:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e raku t; else prove -e raku t; fi

# Extended tests
xtest:
	if [ "${TEST_JOBS}" != "" ]; then prove -j ${TEST_JOBS} -e raku t xt; else prove -e raku t xt; fi

# Content tests
ctest:
	prove --exec raku -r t/07-tabs.t xt/perl-nbsp.t  xt/trailing-whitespace.t

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

clean-cache:
	-rm -rf .cache-doc

clean: clean-html clean-images clean-search

distclean: clean clean-cache
	-rm -rf assets/assetpack.db assets/cache
	-rm -rf highlights/atom-language-perl6/
	-rm -rf highlights/node_modules/
	-rm -rf highlights/package-lock.json
	-rm -rf html/css/app.css
	-rm -rf html/js


test-links: links.txt
	./util/test-links.sh

push: test
	git pull --rebase && git push
