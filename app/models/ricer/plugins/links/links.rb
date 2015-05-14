require 'net/http'

module Ricer::Plugins::Links
  class Links < Ricer::Plugin
    
    def plugin_revision; 2; end

    def upgrade_2; Model::Link.upgrade_1; end

    def on_privmsg
      line.scan(/(\w+:\/\/\w+)/).each do |match|
        add_link(match)
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
      
      byebug
      
      Ricer::Thread.execute do
        url = URI.parse(url)
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) { |http|
          http.request(req)
        }
        byebug
        puts res.body
        byebug        
      end

    end
    
  end
end