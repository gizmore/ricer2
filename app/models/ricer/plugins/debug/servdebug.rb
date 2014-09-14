module Ricer::Plugins::Debug
  class Servdebug < Ricer::Plugin
    
    trigger_is :sdbg
    permission_is :operator
    
    has_usage and has_usage '<server>'
    def execute(server=nil)
      server ||= self.server
      rply(:msg_serverinfo,
        name: server.displayname,
      )
    end

  end
end
