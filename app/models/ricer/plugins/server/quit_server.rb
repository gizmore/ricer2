module Ricer::Plugins::Server
  class QuitServer < Ricer::Plugin
    
    trigger_is :quit_server
    connector_is :irc

    has_usage :execute, '<server>'
    def execute(server)
      server.disconnect
    end
    
  end
end
