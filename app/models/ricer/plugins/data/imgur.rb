require 'json'
require 'open-uri'

module Ricer::Plugins::Data
  class Imgur < Ricer::Plugin

    trigger_is :imgur
    has_usage :execute
    has_usage :execute_msg, '<...message...>'
    def execute
      Ricer::Thread.execute do
        uri = open("https://api.imgur.com/3/gallery/random/random/",
                'Authorization' => 'Client-ID a90bec0cef5bd5c',
                'Accept' => 'application/json'
        )
        buffer = uri.read
        result = ActiveSupport::JSON.decode(buffer)
#       result = JSON.parse(buffer)
        id = rand(7)
        imgur = result['data'][id]
        reply "#{imgur['title']} - #{imgur['link']} \u000303#{imgur['ups']}\u000f\u2934 \u000304#{imgur['downs']}\u000f\u2935"
      end
    end

    def execute_msg(message)
      case message
        when "hot"
          group = "hot"
        when "viral"
          group = "viral"
        when "top"
          group = "top"
        else
          execute
          return false
      end
      page = rand(4)
      Ricer::Thread.execute do
        url = open("https://api.imgur.com/3/gallery/#{group}/top/#{page}.json",
                'Authorization' => 'Client-ID a90bec0cef5bd5c',
                'Accept' => 'application/json'
        )
        buffer = url.read
        result = ActiveSupport::JSON.decode(buffer)
        id = rand(7)
        imgur = result['data'][id]
        reply "#{imgur['title']} - #{imgur['link']} \u000303#{imgur['ups']}\u000f\u2934 \u000304#{imgur['downs']}\u000f\u2935"
      end
    end
  end
end
