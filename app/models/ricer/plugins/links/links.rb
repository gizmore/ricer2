require "net/http"
require "uri"

module Ricer::Plugins::Links
  class Links < Ricer::Plugin
    
    def plugin_revision; 2; end

    def upgrade_2; Model::Link.upgrade_1; end

    def on_privmsg
      line.scan(/(.+:\/\/.+)/).each do |match|
        add_link(match[0])
      end
    end
    
    def add_link(url)
      
      entry = Model::Link.new(
        url: url,
        user_id: sender.id,
        channel_id: (channel.id rescue nil),
        mime_type: nil,
        added: 0
      )
            
      Ricer::Thread.execute do
        request_redir(url) 
      end

    end
    
    def request_redir(url, redirects=10)
      uri = URI.parse(url)
      
      http = Net::HTTP.new(uri.host, uri.port)
      url = uri.request_uri
      request = Net::HTTP::Get.new(uri.request_uri)
      request["open_timeout"] = 10
      response = http.request(request)

      case response
      when Net::HTTPRedirection then
        location = response['location']
        return request_redir(location, redirects - 1)
      end

      mime = response["content-type"].substr_to(";") || response["content-type"]
      
       byebug        
     case mime.substr_to("/")
      when "image"
      when "text"
        case mime
        when "text/html"
          title = extract_html_title(response.body)
        when "text/plain"
          title = response.body.substr.to("\n")
        else
          bot.log_error("Woops... weird mime #{mime}")
        end
      else
        
      end
      byebug        
    end
    
    def extract_html_title(html)
      /title *> *([^<]+) */.match(html)
    end

  end
end
