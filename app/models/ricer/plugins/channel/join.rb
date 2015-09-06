module Ricer::Plugins::Channel
  class Join < Ricer::Plugin
    
    trigger_is :join
    has_priority 70

    permission_is :halfop
    
    has_setting name: :autojoin, type: :boolean, scope: :channel, permission: :operator, default: true

    has_usage :execute_already_there, '<joined_channel>', :allow_trailing => true 
    def execute_already_there(channel)
      rply :err_already_joined
    end
    
    def plugin_loaded
      @passwords = {}
    end

    has_usage '<channel_name>'
    has_usage '<channel_name> <password>'
    def execute(channel_name, password=nil)
      @passwords[channel_name.downcase] = password if password
      rply :msg_trying_to_join
      server.connection.send_join(current_message, channel_name, password)
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
      if channel
        update_password(channel)
        save_channel_setting(channel, :autojoin, true)
      end
    end
    
    def update_password(channel)
      if password = @passwords[channel.name.downcase]
        if (password != channel.password)
          channel.password = password
          channel.save!
          @passwords.delete(channel.name.downcase)
          password = 'iseuhgs9hg'
          bot.log_info("Password for #{channel.name} has been updated.")
        end
      end
    end
    
    # Disable autojoin on a ban
    def on_474
      if channel = Ricer::Irc::Channel.where(:name => args[1], :server_id => server.id).first
        save_channel_setting(channel, :autojoin, false)
      end
    end
    
  end
end
