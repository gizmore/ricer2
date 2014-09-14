# cxg.de pastebin from byte. Thank you!
module Pile
  class Cxg < Base
    
    require 'uri'
    require 'net/http'
    
    def do_upload(title, content, format='text')
      
      cxg_api_key = ENV['CXG_API_KEY'] || 'ricer_clone_without_key'
      uri = URI.parse("http://api.cxg.de/paste?apikey=#{cxg_api_key}")

      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_content_type('application/json', {charset: 'utf-8'})
      request.body = {title: title, content: content, format: format}.to_json
      request.add_field('User-Agent', 'ricer IRC bot; ruby2; https://github.com/gizmore/ricer2')
      response = http.request(request)
      
      #byebug
      if response.code.to_i == 201
        JSON.parse(response.body)['url'] or raise StandardError.new("CXG marked this as spam :(")
      else
        #byebug
        raise StandardError.new("#{response.code} - #{response.inspect}.")
      end
    end
    
  end
end
