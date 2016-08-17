.PHONY: html html-nohighlight test help

html: bigpage
	perl6 htmlify.p6 --parallel=1

html-nohighlight:
	perl6 htmlify.p6 --no-highlight

sparse:
	perl6 htmlify.p6 --no-highlight --sparse=10

webdev-build:
	perl6 htmlify.p6 --no-highlight --sparse=200

bigpage:
	pod2onepage --threads=1 -v --source-path=./doc --exclude=404.pod6,/.git,/precompiled > html/perl6.xhtml

# Common tests that are run by travis with every commit
test:
	prove --exec perl6 -r t

# Extended tests
xtest:
	prove --exec perl6 -r xt t

# Content tests
ctest:
	prove --exec perl6 -r t/tabs.t xt/perl-nbsp.t  xt/trailing-whitespace.t

help:
	@echo "Usage: make [html|html-nohighlight|test|xtest|ctest]"
	@echo ""
	@echo "Options:"
	@echo "   html:             generate the HTML documentation"
	@echo "   html-nohighlight: generate HTML documentation without syntax highlighting"
	@echo " sparse:             generate HTML documention, but only every 10th file"
	@echo "webdev-build:        generate only a few HTML files (useful for testing website changes)"
	@echo "bigpage:             generate HTML documentation in one large file (html/perl6.xhtml)"
	@echo "   test:             run the test suite"
	@echo "  xtest:             run the test suite, including extra tests"
	@echo "  ctest:             run the test suite, content tests only"
	@echo "    run:             run the development webserver"

run:
	@echo "Starting local server…"
	perl app.pl daemon

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

test-links: html/links.txt
	./util/test-links.sh

extract-examples:
	./util/extract-examples.p6 --source-path=./doc/ --prefix=./examples/

push: test
	git pull --rebase && git push
