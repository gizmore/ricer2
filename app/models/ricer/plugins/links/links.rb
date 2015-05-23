require "net/http"
require "uri"

module Ricer::Plugins::Links
  class Links < Ricer::Plugin
    
    def plugin_revision; 4; end

    def upgrade_4; Model::Link.upgrade_1; end

    def on_privmsg
      matches = /[^\s]+:\/\/[^\s]+/.match(line)
      if matches
        matches.to_a.each do |match|
          match.trim!('()') if match.start_with?('(')
          match.trim!('[]') if match.start_with?('[')
          match.trim!('{}') if match.start_with?('{')
          add_link(match)
        end
      end
    end
    
    def add_link(url)
      Ricer::Thread.execute do
        request_redir(url) 
      end
    end
    
    def request_redir(url, redirects=10)
      uri = URI.parse(url)
      
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request["open_timeout"] = 10
      response = http.request(request)

      case response
      when Net::HTTPRedirection then
        location = response['location']
        return request_redir(location, redirects - 1)
      when Net::HTTPError
        bot.log_debug("Error in fetching url: #{response.code}")
        return
      end

      mime = response["content-type"].substr_to(";") || response["content-type"]
      
      write_image = false
      
      case mime.substr_to("/")
      when "image"
        title = url.rsubstr_from('/')
        write_image = true
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

      entry = Model::Link.create!(
        url: url,
        title: title,
        user_id: sender.id,
        channel_id: (channel.id rescue nil),
        mime_type: mime,
        added: 1
      )
      
      entry.save_image(response.body) if write_image
      
    end
    
    def extract_html_title(html)
      begin
        title = /title *> *([^<]+) */.match(html)[1]
      rescue => e
        begin
          title = /h[1-6] *> *([^<]+) */.match(html)[1]
        rescue => e
          title = ""
        end
      end
      title
    end

  end
end
