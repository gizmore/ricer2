module Ricer::Plugins::Channel
  class Join < Ricer::Plugin
    
    trigger_is :join
    permission_is :halfop
    has_priority 70
    
    has_setting name: :autojoin, type: :boolean, scope: :channel, default: true

    has_usage :execute, '<channel_name>'
    def execute(channel_name)
      channel = Ricer::Irc::Channel.by_arg(server, channel_name)
      return rply :err_already_joined if channel && channel.online?
      rply :msg_trying_to_join
      server.connection.send_join(message, channel_name)
    end
    
    def on_001
      bot.log_debug("Channel/Join.ricer_on_server_connected")
      server.channels.each do |channel|
       bot.log_debug("Channel/Join.ricer_on_server_connected #{channel}")
        if get_channel_setting(channel, :autojoin)
           bot.log_debug("Channel/Join.ricer_on_server_connected #{channel} is autojoin")
          server.connection.send_join(message, channel.name)
        end
      end
    end
    
    # Disable autojoin on a ban
    def on_474
      channel = Ricer::Irc::Channel.by_arg(server, args[1])
      channel_setting(channel, :autojoin).save_value(false)
    end
    
  end
end