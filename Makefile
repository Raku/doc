.PHONY: html html-nohighlight test help

html:
	perl6 htmlify.p6

html-nohighlight:
	perl6 htmlify.p6 --no-highlight

sparse:
	perl6 htmlify.p6 --no-highlight --sparse=10

test:
	prove --exec perl6 -r t

help:
	@echo "Usage: make [html|html-nohighlight|test]"
	@echo ""
	@echo "Options:"
	@echo "   html:             generate the HTML documentation"
	@echo "   html-nohighlight: generate HTML documentation without syntax highlighting"
	@echo "   test:             run the test suite"

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
