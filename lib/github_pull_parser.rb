###############################################################################
##
##  The entry point into the parsing program. 
##  The bin/review program should call this with the command 
##  line arguments. 
##  Customized for the GitHub API. 
##
################################################################################

require 'json'
require 'http'
require 'yaml'
require 'diff_parser'

module PullParser

  class GitHubParser

    def self.start(url, repo, detailed_output)
      pull_url = construct_url(url, repo)
      http = HTTPHelper.new(pull_url)
      http.make_get_request

      unless http.get_response_content_type.eql? 'application/json'
         raise "Received a non JSON response from #{url}. Did the API change?"
      end

      analyze_pulls(http.get_response_body, detailed_output)
    end

    def self.construct_url(url, repo)
      pull_url = url + '/' + repo + '/pulls'
      pull_url
    end

    def self.analyze_pulls(body, detailed_output)
      json = JSON.parse(body)

      map = json.map {|pull| {:url => pull['html_url'], :diff => pull['diff_url'], :title => pull['title']} }

      diff_parser = DiffParser.new()
      result_map = {}
      map.each do |e| 
        url = e[:url]
        diff_url = e[:diff]

        http_client = HTTPHelper.new(diff_url)
        http_client.make_get_request

        # more ruby like to do this?
        # next unless response_type.eql? 'text/plain'
        unless http_client.get_response_content_type.eql? 'text/plain'
          puts "Found unrecognizable response for URL - #{diff_url}"
          next
        end

        diff_map = diff_parser.parse(http_client.get_response_body)
        result_map[url] = diff_map
      end

      if detailed_output
        print_detailed_output(result_map)
      else
        print_output(result_map)
      end

    end

    def self.print_detailed_output(map)
      map.each do |key, diff|
        puts "#{key} - " + (diff.length > 0 ? "Interesting" : "Not Interesting")
        if diff.length > 0
          puts "----- INTERESTING OBJECTS -----"
          puts YAML.dump(diff)
        end
      end
    end

    def self.print_output(map)
      map.each do |key, diff|
        puts "#{key} - " + (diff.length > 0 ? "Interesting" : "Not Interesting")
      end
    end

  end

end
