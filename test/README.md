# 🧪 diff-so-fancy unit tests

This directory contains various unit tests to ensure correct functionality of
d-s-f. You will need the
[bats testing system](https://github.com/bats-core/bats-core) to run the unit
tests.

## 🏃 Running the tests

* Run the entire suite of tests: `bats test`
* Run only tests that match the filter "color": `bats test -f color`
* Run only the tests related to bugs: `bats test/bugs.bats`

## 🎨 Testing ANSI colors

Due to the nature of the coloring used with d-s-f we utilize the
`ansi-reveal.pl` script in testing. This will convert raw ANSI strings into
human readable text that is easier to parse and write tests against.
