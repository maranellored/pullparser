PullParser
==========

A simple program that helps analyze pull requests for a given git-hub project.

The pull requests are analyzed for interesting words. Some of the interesting words currently considered are
* All changes to the Gemfile or .gemspec files in the project root.
* All changes that contain the following expressions as individual words
    - raise
    - %x
    - .write
    - exec
    - /dev/null

Changes to any file in the spec/ directory are discarded.

Usage
-----

To use, run the following
    $ bin/review owner/repo

For example, run
    $ bin/review ruby/ruby

License
-------

See [LICENSE][LICENSE] file
