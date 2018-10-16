#!/bin/bash

set -e


case "${BUILDENV}" in
    docker)
      docker pull jjmerelo/perl6-doccer
    ;;
    whateverable)
      sudo -E apt-add-repository -y "ppa:ubuntu-toolchain-r/test"
      sudo -E apt-get -yq update &>> ~/apt-get-update.log
      sudo -E apt-get -yq --no-install-suggests --no-install-recommends --force-yes install graphviz g++-4.8 ruby-sass
      wget https://whateverable.6lang.org/HEAD.tar.gz
      tar -xv --absolute-names -f HEAD.tar.gz
      HEAD_BUILD=$(echo /tmp/whateverable/rakudo-moar/*)
      export PATH="$PATH:$HEAD_BUILD/bin"
      ZEF_BUILD="$HEAD_BUILD/share/perl6/site/bin"
      git clone https://github.com/ugexe/zef.git && cd zef && perl6 -Ilib bin/zef install . && cd ..
      export PATH="$PATH:$ZEF_BUILD"
      zef --/tap-harness  install IO::Socket::SSL # Needs to be installed in advance
      zef --/tap-harness --depsonly install .
      mkdir build
    ;;
esac
