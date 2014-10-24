module Ricer::Plugins::Channel
  class Part < Ricer::Plugin
    
    trigger_is :part
    
    has_usage :execute, '',          permission: :operator, scope: :channel
    has_usage :execute, '<channel>', permission: :ircop
    
    def execute(channel=nil)
      channel ||= self.channel
      disable_autojoin(channel)
      server.connection.send_part(current_message, channel.name) if channel.online
    end
    
    def disable_autojoin(channel)
      join = get_plugin('Channel/Join')
      if join.get_channel_setting(channel, :autojoin)
        join.save_channel_setting(channel, :autojoin, false)
        rply :msg_autojoin_off
      end
    end
    
  end
end
