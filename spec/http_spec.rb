#################################################
##
##  Test for the http class
##
#################################################

require 'http'

describe PullParser::HTTPHelper do

  before :all do
    @http_helper = PullParser::HTTPHelper.new "https://www.google.com"
  end

  describe '#new' do
    it 'ensures that we get a HTTPHelper object' do
      expect(@http_helper).to be_an_instance_of(PullParser::HTTPHelper)
    end
  end

  describe '#make_get_request' do
    it 'Tests an URL by making HTTP Get requests' do
      expect {@http_helper.get_response_body}.to raise_error
      @http_helper.make_get_request
      expect(@http_helper.get_response_body).to_not be_nil
    end

    it 'Tests that we get a successful error code' do
      expect(@http_helper.get_response_content_type).to eql('text/html')
    end
  end

  describe '#make_get_request' do
    failing_helper = PullParser::HTTPHelper.new 'https://abcdefghij.in'
    it 'Ensures that the above URL doesnt exist' do
      expect {failing_helper.make_get_request}.to raise_error
    end
  end

  describe '#new' do
    wrong_url = 'abcd12453'
    it 'Ensures that an illegal URL cannot construct an object' do
      expect {PullParser::HTTP.new(wrong_url)}.to raise_error
    end
  end

end
