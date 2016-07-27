.PHONY: html html-nohighlight test help

html: bigpage
	perl6 htmlify.p6 --parallel=1

html-nohighlight:
	perl6 htmlify.p6 --no-highlight

sparse:
	perl6 htmlify.p6 --no-highlight --sparse=10

bigpage:
	pod2onepage --threads=1 -v --source-path=./doc --exclude=404.pod6,/.git,/precompiled > html/perl6.xhtml

# Common tests that are run by travis with every commit
test:
	prove --exec perl6 t/00-load.t t/pod-htmlify.t t/tabs.t t/typegraph.t t/pod-convenience.t t/pod6.t

# Extended tests
xtest:
	prove --exec perl6 -r t

# Content tests
ctest:
	prove --exec perl6 -r t/tabs.t t/trailing_whitespace.t

help:
	@echo "Usage: make [html|html-nohighlight|test|xtest|ctest]"
	@echo ""
	@echo "Options:"
	@echo "   html:             generate the HTML documentation"
	@echo "   html-nohighlight: generate HTML documentation without syntax highlighting"
	@echo "   test:             run the test suite"
	@echo "  xtest:             run the test suite, including extra tests"
	@echo "  ctest:             run the test suite, content tests only"

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

clean-images:
	rm -f html/images/type-graph*

clean-search:
	rm -f html/js/search.js

clean: clean-html clean-images clean-search

test-links: html/links.txt
	./util/test-links.sh

push: test
	git pull --rebase && git push
