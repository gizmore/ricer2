module Ricer::Plugins::Debug
  class Servdebug < Ricer::Plugin
    
    trigger_is :sdbg
    
    has_usage :execute, '[<server>]'
    def execute(server)
      server = self.server if server.nil?
      rply :msg_serverinfo,
        name: server.displayname
    end

  end
end
