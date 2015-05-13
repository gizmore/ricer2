module Ricer::Plugins::Links
  class Links < Ricer::Plugin
    
    def plugin_revision; 2; end

    def upgrade_2; Model::Link.upgrade_1; end

    def on_privmsg
      match = /(\w+:\/\/\w+)/.match(line)
      if match
        match.each do |m|
          add_link(m)
        end
      end
    end
    
    def add_link(url)
      byebug
      
    end
    
  end
end