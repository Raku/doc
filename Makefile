.PHONY: html test

html:
	perl6 htmlify.p6

test:
	prove --exec perl6 -r t
