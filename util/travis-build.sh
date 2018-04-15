#!/bin/bash

set -e

source travis_retry.sh

case "${BUILDENV}" in
    docker)
      docker pull jjmerelo/test-perl6
      docker run -t -v  $TRAVIS_BUILD_DIR:/test  --entrypoint="/bin/sh" jjmerelo/perl6-doccer  -c zef --/tap-harness --force --/test install LWP::Simple
      docker run -t -v  $TRAVIS_BUILD_DIR:/test  --entrypoint="/bin/sh" jjmerelo/perl6-doccer  -c zef --/tap-harness --depsonly install .
    ;;
    whateverable)
      wget https://whateverable.6lang.org/HEAD.tar.gz
      tar -xv --absolute-names -f HEAD.tar.gz
      HEAD_BUILD=$(echo /tmp/whateverable/rakudo-moar/*)
      export PATH="$PATH:$HEAD_BUILD/bin"
      ZEF_BUILD="$HEAD_BUILD/share/perl6/site/bin"
      git clone https://github.com/ugexe/zef.git && cd zef && perl6 -Ilib bin/zef install . && cd ..
      export PATH="$PATH:$ZEF_BUILD"
      travis_retry zef --/tap-harness --force --/test install LWP::Simple
      travis_retry zef --/tap-harness --depsonly install .
    ;;
esac
