#!/bin/bash

case "${BUILDENV}" in
    docker)
	docker run -t -v $TRAVIS_BUILD_DIR:/test jjmerelo/test-perl6
	docker run -t -v  $TRAVIS_BUILD_DIR:/test  --entrypoint="/bin/sh" jjmerelo/perl6-doccer  -c perl6 htmlify.p6 --no-highlight
    ;;
    whateverable)
	P6_DOC_TEST_VERBOSE=1 make test
	perl6 htmlify.p6 --no-highlight
    ;;
esac
