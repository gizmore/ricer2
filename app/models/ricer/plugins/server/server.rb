module Ricer::Plugins::Server
  class Server < Ricer::Plugin
    
    is_show_trigger :server, :for => Ricer::Irc::Server
    
    def display_show_item(number, server)
      
    end
    
  end
end
