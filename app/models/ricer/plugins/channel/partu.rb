module Ricer::Plugins::Channel
  class Partu < Ricer::Plugin
    
    trigger_is :part
    permission_is :ircop
    scope_is :user
    
    has_usage :execute, '<channel>'
    def execute(channel)
      join = get_plugin('Channel/Join')
      if join.get_channel_setting(channel, :autojoin)
        join.save_channel_setting(channel, :autojoin, false)
        rply :msg_autojoin_off
      end
      server.connection.send_part(message, channel.name)
    end
    
  end
end
