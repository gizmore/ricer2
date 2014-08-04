module Ricer::Plugins::Server
  class Servers < Ricer::Plugin
    
    is_list_trigger :servers, :for => Ricer::Irc::Server
    
    def display_list_item(number, server)
      
    end
    
  end
end
