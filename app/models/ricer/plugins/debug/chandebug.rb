module Ricer::Plugins::Debug
  class Chandebug < Ricer::Plugin
    
    trigger_is :cdbg
    
    has_usage :execute_channel, '<channel>'
    def execute_channel(channel)
      rply :msg_chaninfo,
        id: channel.id,
        name: channel.displayname,
        server: channel.server.displayname,
        channel: channel
    end

    has_usage
    def execute
      execute_channel(channel)
    end
    
  end
end
