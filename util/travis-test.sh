#!/bin/bash

set -x
set -e

case "${BUILDENV}" in
    docker)
      docker run -t -v $TRAVIS_BUILD_DIR:/test jjmerelo/perl6-doccer
      docker run -t -v $TRAVIS_BUILD_DIR:/test --entrypoint="/bin/sh" jjmerelo/perl6-doccer -c "perl6 htmlify.p6 --no-highlight"
    ;;
    whateverable)
      HEAD_BUILD=$(echo /tmp/whateverable/rakudo-moar/*)
      export PATH="$PATH:$HEAD_BUILD/bin"
      ZEF_BUILD="$HEAD_BUILD/share/perl6/site/bin"
      export PATH="$PATH:$ZEF_BUILD"
      P6_DOC_TEST_VERBOSE=1 make test
      perl6 htmlify.p6 --no-highlight
    ;;
esac
