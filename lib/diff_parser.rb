###############################################################################
##
##  Helps parse diffs.
##  Assumes the unified diff format as specified here
##  http://en.wikipedia.org/wiki/Diff#Unified_format
##  Customized slightly for the git diff format. 
##
##  Parsing other formats will lead to errors.
##
###############################################################################
require 'yaml'
require 'json'

module PullParser

  class DiffParser
    REGEX_FILE_START = /^diff --git\s/
    REGEX_FILE_DEL = /^-{3}\s/
    REGEX_FILE_ADD = /^\+{3}\s/
    REGEX_SPEC_DIR = /^spec\//
    REGEX_GEMFILE = /^Gemfile$/
    REGEX_GEMSPEC = /^\.gemspec$/
    REGEX_LINE_MODIFIED = /^[+-]{1}/
    REGEX_INTERESTING_ARRAY = [ /(^|\s)\/dev\/null(\s|$)/,
                                /(^|\s)%x(\s|$)/,
                                #/.%x./,
                                /(^|\s)raise(\s|$)/,
                                /(^|\s)\.write(\s|$)/,
                                #/.\.write./,
                                /(^|\s)exec(\s|$)/ ]

    # Scans the given diff file for interesting items.
    # The algorithm used is as follows -
    # - Figure out the file name.
    # - Check if the file is in the spec directory in the project root
    #   - if yes, then ignore the file
    # - Check if the file is a Gemfile or a gemspec file in the project root
    #   - if yes, track every modification to this file
    # - Check if the line has any of the interesting expressions in it
    #   - Checks each of the expressions and quits upon finding the first match
    def parse(data)
      old_file = ""
      new_file = ""
      spec_file = false
      gem_file = false
      file = ""

      diff_map = {}
      interesting_mods = []

      data.each_line do |line|
        if is_start_of_new_file?(line)
          if interesting_mods.length > 0
            diff_map[file] = interesting_mods
          end
          spec_file = false
          gem_file = false
          old_file = ""
          new_file = ""
          file = ""
          interesting_mods = []
        end

        if spec_file
          next
        end

        if is_deleted_file?(line)
          # A file was deleted!
          old_file = get_file(line)
          next
        end

        if is_new_file?(line)
          # A file was added.
          new_file = get_file(line)

          # Check if the file is in the spec directory
          spec_file = is_file_in_spec_dir?(new_file)

          unless old_file.eql? new_file
            # The files are different. Either deleted or created as new
            spec_file |= is_file_in_spec_dir?(old_file)
          end

          # Check if either the old/new file is a Gemfile or a gemspec
          if is_gem_file?(old_file) or is_gem_file?(new_file)
            gem_file = true
          end

          file = get_current_file(old_file, new_file)
          next
        end

        if is_modified_line?(line)
          if gem_file
            interesting_mods << line
            next
          end

          if is_interesting?(line)
            interesting_mods << line
          end
        end
      end

      # We might still have an interesting left-over file.
      # Add it to our map if it is true
      if interesting_mods.length > 0
        diff_map[file] = interesting_mods
      end

      diff_map
    end

    # Checks if the line represents the start of a new file.
    # In a git diff this is represented using the following format
    # diff --git a/filename b/filename
    def is_start_of_new_file?(line)
      if line.scan(REGEX_FILE_START).size == 1
        return true
      end

      false
    end

    # Checks if the given line represents a file addition. 
    # In a git diff, this is represented using the following format
    # +++ a/path/to/file
    def is_new_file?(line)
      if line.scan(REGEX_FILE_ADD).size == 1
        return true
      end

      false
    end

    # Checks if the given line represents a file deletion.
    # In a git diff this is represented using the following format
    # --- a/path/to/file
    def is_deleted_file?(line)
      if line.scan(REGEX_FILE_DEL).size == 1
        return true
      end

      false
    end

    # Checks if the given line is either a new or a deleted line
    # In a git diff this is represented using the following format
    # +  text
    # - text
    def is_modified_line?(line)
      if line.scan(REGEX_LINE_MODIFIED).size == 1
        return true
      end

      false
    end

    # Gets the filename from a unified diff addition/deletion line
    # The line is in either of the two forms below
    # "--- a/path/to/original"
    # "+++ b/path/to/new"
    #
    # The git diff adds two leading characters to the file name, which can be
    # deleted. These are used to denote the two versions of the file - a and b
    # Eg: a/path/to/file becomes path/to/file
    #
    # If the string is /dev/null, it implies that the file has either been
    # created anew or has been deleted.
    def get_file(string)
      git_string = string.split(' ')[1]
      if git_string.eql? '/dev/null'
        return nil
      end

      git_string[2..-1]
    end

    # Checks if the file is from the spec directory
    # If yes, the returns true, else false
    def is_file_in_spec_dir?(filename)
      unless filename.nil?
        if filename.scan(REGEX_SPEC_DIR).size == 1
          return true
        end
      end

      false
    end

    # Checks the filename to see if it is a Gemfile
    # or is a .gemspec file
    # Assumes that the interesting Gemfile is only in the project root
    # directory. If a Gemfile is found deeper in the project hierarchy, it is a
    # ignored and treated as a regular file
    def is_gem_file?(filename)
      unless filename.nil?
        if filename.scan(REGEX_GEMFILE).size == 1
          return true
        elsif filename.scan(REGEX_GEMSPEC).size == 1
          return true
        end
      end

      false
    end

    # Retrieves the current filename that is being modified.
    # Needs to parse both the old_file and the new_file since the file may have
    # been either deleted or added. If so, then one of old_file or new_file
    # will be nil
    def get_current_file(old_file, new_file)
      # Either one can be nil but not both. 
      # If both are not nil, they have to be equal. 
      # return the old_file if its not null
      old_file.nil? ? new_file : old_file
    end

    # Checks if the given line is interesting.
    # Uses the standard defined array of interesting expressions to check if
    # the line matches anyone of them
    def is_interesting?(line)
      REGEX_INTERESTING_ARRAY.each do |regex|
        if line.scan(regex).size > 0
          return true
        end
      end

      false
    end

  end  # End of class
end  # End of module
