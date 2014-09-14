module Ricer::Plugins::Debug
  class Chandebug < Ricer::Plugin
    
    trigger_is :cdbg
    permission_is :operator
    
    has_usage :execute, '', :scope => :channel
    has_usage '<channel>'
    def execute(channel=nil)
      channel ||= self.channel
      rply(:msg_chaninfo,
        channel: channel.displayname,
        server: channel.server.displayname,
      )
    end
    
  end
end
