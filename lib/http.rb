################################################################################
##
##  A basic HTTP helper class that wraps around the ruby http library
##  Allows to make HTTP requests using the 'net/http' library
##
##  Store responses in the class, rather than trying to return a specific
##  attributes of the original HTTP response object.
##
################################################################################

require 'uri'
require 'net/https'

module PullParser
  class HTTPHelper

    def initialize(url)
       @uri = URI.parse(url)
       @http = Net::HTTP.new(@uri.host, @uri.port)

       @http.use_ssl = true
       @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
       @response = nil
    end

    def make_get_request
      request = Net::HTTP::Get.new(@uri.request_uri)

      @response = @http.request(request)

      unless @response.kind_of? Net::HTTPSuccess
        puts "Cannot talk to #{@uri.to_s}. Get request failed."
        puts @response.message
        raise "HTTP GET failed\n #{@response.message}"
      end

    end

    def get_response_content_type
      unless @response.nil?
        return @response.content_type
      end

      raise "HTTP request not made. Call make_get_request before me"
    end

    def get_response_body
      unless @response.nil?
        return @response.body
      end

      raise "HTTP request not made. Call make_get_request before me"
    end

  end # End of HTTPHelper class

end # End of module
