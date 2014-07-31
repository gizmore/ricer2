module Ricer::Plugins::Debug
  class Servdebug < Ricer::Plugin
    
    trigger_is :sdbg
    
    has_usage :execute, ''
    has_usage :execute_s, '<server>'
    def execute(); execute_s(server); end
    def execute_s(server)
      rply :msg_serverinfo,
        name: server.displayname
    end

  end
end
