PullParser
==========

A simple program that helps analyze pull requests for a given git-hub project.
Currently is hard coded to work with Github only. 

The pull requests are analyzed for interesting words. Some of the interesting words currently considered are
* All changes to the Gemfile or .gemspec files in the project root.
* All changes that contain the following expressions as individual words
    - raise
    - %x
    - .write
    - exec
    - /dev/null

Changes to any file in the spec/ directory in the project root are discarded.

**NOTE**: %x and .write are a little different. They can occur as substrings of an expression. 
For eg. puts(%x('ls')) or f.write('hello, world')

This is ignored in the current use case, but the regex to match this can be easily modified to consider 
these cases. 

Usage
-----

To use, run the following
```
$ bin/review owner/repo
```

By default, the program only prints if the objects are interesting or not. If you are interested in learning more
about the interesting pull requests and what data they contain, run the script with the '-d' flag
```
$ bin/review owner/repo -d
```

For example, run
```
    $ bin/review ruby/ruby
    $ bin/review ruby/ruby -d
```

License
-------

See [LICENSE][LICENSE] file
