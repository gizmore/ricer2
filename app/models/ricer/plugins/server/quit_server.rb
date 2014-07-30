module Ricer::Plugins::Server
  class QuitServer < Ricer::Plugin
    
    has_usage :execute, '<server>'
    def execute(server)
      server.disconnect
    end
    
  end
end