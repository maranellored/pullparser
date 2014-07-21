###############################################################################
##
## Tests for the diff_parser class
##
###############################################################################

require 'diff_parser'

describe PullParser::DiffParser do

  before :all do 
    @diff_parser = PullParser::DiffParser.new
  end

  describe '#new' do
    it 'ensures that we have an object of the DiffParser class' do
      expect(@diff_parser).to be_an_instance_of(PullParser::DiffParser)
    end
  end

  describe '#is_interesting?' do
    it 'checks if the given line is interesting? or not' do
      expect(@diff_parser.is_interesting?('hello, world - this is /dev/null ')).to be
      expect(@diff_parser.is_interesting?('hello, world - this is /dev/null')).to be

      expect(@diff_parser.is_interesting?('we execute like this - %x ("ls")')).to be
      expect(@diff_parser.is_interesting?('%x ("ls") should list all files')).to be

      expect(@diff_parser.is_interesting?('raise a ruckus!!!')).to be
      expect(@diff_parser.is_interesting?('Does this even get a raise')).to be

      expect(@diff_parser.is_interesting?('go to the .write function')).to be
      expect(@diff_parser.is_interesting?('fork and exec and multiply')).to be
    end

    it 'checks that the lines dont match any of the given regex' do
      expect(@diff_parser.is_interesting?('does that deserve praise?')).not_to be
      expect(@diff_parser.is_interesting?('hello, world - bye, bye!')).not_to be
      expect(@diff_parser.is_interesting?('Random nonsense? %x(%y%z)')).not_to be
      expect(@diff_parser.is_interesting?('Is this.write even correct?')).not_to be
    end
  end

  describe '#get_current_file' do
    it 'retrieves the current filename from either of the strings' do
      expect(@diff_parser.get_current_file('hello', 'hello')).to eql('hello')
      expect(@diff_parser.get_current_file('hello', nil)).to eql('hello')
      expect(@diff_parser.get_current_file(nil, 'hello')).to eql('hello')
      expect(@diff_parser.get_current_file(nil, nil)).to eql(nil)
    end
  end

  describe '#is_gem_file?' do
    it 'checks if the given file matches the Gemfile spec' do
      expect(@diff_parser.is_gem_file?('Gemfile')).to be
      expect(@diff_parser.is_gem_file?('.gemspec')).to be
    end

    it 'checks that the file is not a gemfile' do
      expect(@diff_parser.is_gem_file?('HolaGemfile')).not_to be
      expect(@diff_parser.is_gem_file?('.gemspecification')).not_to be
    end
  end

  describe '#is_file_in_spec_dir?' do
    it 'checks if the top level directory is a spec directory' do
      expect(@diff_parser.is_file_in_spec_dir?('spec/bla/foo')).to be
      expect(@diff_parser.is_file_in_spec_dir?('specification/baz')).not_to be
      expect(@diff_parser.is_file_in_spec_dir?('/spec/foo/bar_spec')).not_to be
      expect(@diff_parser.is_file_in_spec_dir?('foo/bar/spec/hello')).not_to be
    end
  end

  describe '#get_file' do
    it 'retrieves the file name if its not /dev/null' do
      expect(@diff_parser.get_file('+++ a/path/to/file')).to eql('path/to/file')
      expect(@diff_parser.get_file('--- /path/to/file')).not_to eql('/path/to/file')
      expect(@diff_parser.get_file('+ /dev/null')).to eql(nil)

      expect {@diff_parser.get_file('/path/to/file')}.to raise_error
    end
  end

  describe '#is_start_of_new_file?' do
    it 'checks if the given line denotes start of a new file' do
      expect(@diff_parser.is_start_of_new_file?('diff --git a/file b/file')).to be
      expect(@diff_parser.is_start_of_new_file?('diff --git bla foo bar')).to be
      expect(@diff_parser.is_start_of_new_file?(' diff --git a/foo b/foo')).not_to be
      expect(@diff_parser.is_start_of_new_file?('diff -git a/bar b/bar')).not_to be
    end
  end

  describe '#is_new_file?' do
    it 'checks if this line represents a new file' do
      expect(@diff_parser.is_new_file?('+++ /a/file')).to be
      expect(@diff_parser.is_new_file?('+++    /another/file')).to be
      expect(@diff_parser.is_new_file?('--- not/a/file/start')).not_to be
      expect(@diff_parser.is_new_file?('+ a/modified/line')).not_to be
    end
  end

  describe '#is_deleted_file?' do
    it 'checks if this line represents a deleted file' do
      expect(@diff_parser.is_deleted_file?('--- deleted/file')).to be
      expect(@diff_parser.is_deleted_file?('---     another/deletion')).to be
      expect(@diff_parser.is_deleted_file?('-- this/should/be/false')).not_to be
      expect(@diff_parser.is_deleted_file?('-+/random/string')).not_to be
    end
  end

  describe '#is_modified_line?' do
    it 'checks if this line is a modified line' do
      expect(@diff_parser.is_modified_line?('+ Text')).to be
      expect(@diff_parser.is_modified_line?('- Text')).to be
      expect(@diff_parser.is_modified_line?('+  Text')).to be
      expect(@diff_parser.is_modified_line?('-  Text')).to be
      expect(@diff_parser.is_modified_line?('+Text')).to be
      expect(@diff_parser.is_modified_line?('-Text')).to be

      expect(@diff_parser.is_modified_line?('T+E-X-T')).not_to be
      expect(@diff_parser.is_modified_line?('/is/false')).not_to be
    end
  end
end
