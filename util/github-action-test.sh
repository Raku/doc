#!/bin/bash -

# This script is run by the step 'Run tests' in the GitHub workflow "test"
# See .github/workflows/test.yml

set -ex
set -o pipefail

: ${TEST_IMAGE:=docker.io/jjmerelo/perl6-doccer:latest}
: ${RAKU_DOC_TEST_VERBOSE:=1}

# this default value allows one to run a command like
# ./util/github-action-test.sh
: ${GITHUB_WORKSPACE:=${PWD}}

# if no argument is given run tests from t/
if [[ $# -eq 0 ]]; then
  set -- t
fi

docker run -t \
  -v "${GITHUB_WORKSPACE}":/test:Z \
  --entrypoint env \
  "${TEST_IMAGE}" \
  RAKU_DOC_TEST_VERBOSE=${RAKU_DOC_TEST_VERBOSE} \
  prove6 "$@"
