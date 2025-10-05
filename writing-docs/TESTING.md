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

# Frequency

## CI

Every commit should run a basic set of tests with `make xtest`. As of Feb 2023, we
are updating our CI, so this is currently disabled. C<NOTE> The author tests in `xt/`
are not currently passing. If this causes difficulty, please submit the PR with
failing tests and someone will still review it.

You can run the basic tests against a subset of files with

```
$ TEST_FILES="doc/Language/faq.rakudoc doc/Type/Complex.rakudoc" make test
```

Or against everything that you haven't committed yet:
```
$ TEST_FILES=$(git ls-files --modified) make xtest
```

## NETWORK_TESTING

Some tests make network connections to verify data; if this environment variable is not
set, those tests will be skipped.

## PR

Every pull request should pass the full set of tests with `make xtest`

In your branch or fork, if you have non-committed changes for some files, you can run:

```
$ util/test-modified.sh
```

Or to run specific files regardless of their git status:

```
$ TEST_FILES="doc/Language/faq.rakudoc doc/Type/Complex.rakudoc" make xtest
```

If you see some tests are skipped (spelling or signature checks), that's fine.
