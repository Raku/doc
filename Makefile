.PHONY: html html-nohighlight test

html:
	perl6 htmlify.p6

html-nohighlight:
	perl6 htmlify.p6 --no-highlight

test:
	prove --exec perl6 -r t
