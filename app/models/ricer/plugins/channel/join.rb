module Ricer::Plugins::Channel
  class Join < Ricer::Plugin
    
    trigger_is :join
    permission_is :halfop
    has_priority 70
    
    has_setting name: :autojoin, type: :boolean, scope: :channel, default: true

    has_usage :execute_already_there, '<joined_channel>'
    def execute_already_there(channel)
      rply :err_already_joined
    end

    has_usage '<channel_name>'
    def execute(channel_name)
      rply :msg_trying_to_join
      server.connection.send_join(current_message, channel_name)
    end
    
    # Bootup autojoins
    def on_001
      server.channels.each do |channel|
        if get_channel_setting(channel, :autojoin)
          server.connection.send_join(current_message, channel.name)
        end
      end
    end
    
    # Re-enable autojoin
    def on_join
      save_channel_setting(channel, :autojoin, true)
    end
    
    # Disable autojoin on a ban
    def on_474
      if channel = Ricer::Irc::Channel.where(:name => args[1], :server_id => server.id).first
        save_channel_setting(channel, :autojoin, false)
      end
    end
    
  end
end
