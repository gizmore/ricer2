require "net/http"
require "uri"

module Ricer::Plugins::Links
  class Links < Ricer::Plugin
    
    revision_is 4
    author_is "gizmore@wechall.net"

    def upgrade_5; Model::Link.upgrade_1; end

    def on_privmsg
      begin
        matches = /[^\s]+:\/\/[^\s]+/.match(line)
        if matches
          matches.to_a.each do |match|
            match.trim!('()') if match.start_with?('(')
            match.trim!('[]') if match.start_with?('[')
            match.trim!('{}') if match.start_with?('{')
            match.rtrim!("])}\x01")
            add_link(match)
          end
        end
      rescue ArgumentError => e
        bot.log_exception(e, false)
      end
    end
    
    def add_link(url)
      Ricer::Thread.execute do
        request_redir(url) 
      end
    end
    
    def request_redir(url, redirects=10)
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request["open_timeout"] = 10
        http.use_ssl = (uri.scheme == "https")
        response = http.request(request)
      rescue => e
        bot.log_error(e.message)
        return
      end

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
          title = response.body.substr_to("\n")
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
      
      announce_new_link
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
      HTMLEntities.new.decode(title.force_encoding('UTF-8'))
    end
    
    def announce_new_link
      
    end

  end
end
