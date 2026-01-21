# Testing

Having learned our lessons about how easy it is to introduce typos over the years,
we have several tests in the repository to help us keep our content as clean as
possible.

# Setup

Before running the tests, you may need to install modules required by the tests:

```
$ zef install --deps-only .
```

We depend on something that depends on graphviz, but we don't need it ourselves.
You can skip it with:

```
$ zef install --deps-only --exclude="dot" --/test .
```

## Continuous Integration / Pull Requests

Each commit/PR will trigger the CI (only for the files that changed) and run the tests.

Every pull request should pass the CI tests.

## Local testing

In your branch or fork, if you have non-committed changes for some files, you can run:

```
$ util/test-modified.sh
```

Or to run all tests on specific files regardless of their git status:

```
$ TEST_FILES="doc/Language/faq.rakudoc doc/Type/Complex.rakudoc" RAKULIB=. make xtest
```

Author tests that are in `xt/` may not pass or have prerequisites.

You can run the basic tests against a subset of files with

```
$ TEST_FILES="doc/Language/faq.rakudoc doc/Type/Complex.rakudoc" zef test --verbose .
```

Or all tests against everything that you haven't committed yet:
```
$ TEST_FILES=$(git ls-files --modified) RAKULIB=. make xtest
```

## NETWORK_TESTING

Some tests make network connections to verify data; if this environment variable is not
set, those tests will be skipped.
