module Ricer::Plugins::Rice
  class Connect < Ricer::Plugin
    
    # We have to be called first!
    def priority; 0; end 
    def core_plugin?; true; end
    # We have to be called first!
    
    def ricer_on_server_handshake
      bot.log_debug "Ricer::Plugins::Rice::Connect.ricer_on_server_handshake()"
#      server.next_nickname
      server.login(@message)
    end
    
    def ricer_on_server_connected
      bot.log_debug "Ricer::Plugins::Rice::Connect.ricer_on_server_handshake()"
      if server.persisted?
        server.online = true
        server.save!
        server.global_cache_add
      end
    end
    
    def on_001
      process_event('ricer_on_server_authenticated') unless server.nickname.can_authenticate?
      server.authenticate(@message)
    end
    
    def on_002
      bot.log_debug('Connect.on_002: '+message.raw)
    end
    
    def on_nick
      old_user = create_user(sender_nickname)
      new_user = create_user(args[0])
      @message.sender = new_user
      Ricer::Irc::Chanperm.where(:user_id => old_user.id, :online => true).each do |chanperm|
        new_user.ricer_on_joined_channel(chanperm.channel)
      end
    end
    
    def on_notice
      on_privmsg unless @message.prefix.index('!').nil? rescue nil
    end

    def on_privmsg
      bot.log_debug('Rice/Connect.on_privmsg')
      # Every privmsg origins from a user
      @message.sender = create_user(sender_nickname)
      # And maybe belongs to a channel
      @message.receiver = load_channel(@message.args[0])
      
      # Set the hostmask
#      @message.sender.hostmask = @message.prefix

      # Else it belongs to bot itself
#     @message.receiver = bot if message.receiver.nil?
    end
    
    def on_ping
      server.connection.send_pong(@message, args[0])
    end
    
    def on_error
      server.disconnect!(@message)
    end
    
    def on_quit
      @message.sender = create_user(sender_nickname)
      unless @message.is_ricer?
        @message.sender.ricer_on_parted_server(server)
      end
    end
    
    def on_join
      @message.sender = create_user(sender_nickname)
      @message.receiver = channel = create_channel(args[0])
      channel.ricer_on_join
      user.ricer_on_joined_channel(channel)
      process_event('ricer_on_user_joined') unless ricer_itself?
    end
    
    def on_part
      @message.sender = create_user(sender_nickname)
      @message.receiver = channel = create_channel(args[0])
      if @message.is_ricer?
        channel.ricer_on_part
        Chanperm.where(:channel_id => channel.id).update_all(:online => false)
      end
    end
    
    def on_kick
      puts @message
      byebug
      puts "HI"
    end
    
    def on_353
      @message.receiver = channel = create_channel(args[2])
      args[3].split(' ').each do |username|
        username.strip!
        unless username.empty?
          user = create_user(Ricer::Irc::Nickname.nickname_from_prefix(username))
          user.ricer_on_joined_channel(channel, Ricer::Irc::Permission.bits_from_nickname(username))
        end
      end
    end
    
    def on_433
      server.next_nickname
      server.send_nick(@message)
    end
    
    private
    
    def sender_nickname
      Ricer::Irc::Nickname.nickname_from_message(@message)      
    end
    
    def load_user(nickname)
      Ricer::Irc::User.where({server_id: server.id, nickname: nickname}).first
    end
    
    def create_user(nickname)

      created = false
      user = load_user(nickname)
      if user.nil?
        user = Ricer::Irc::User.create!({server_id: server.id, nickname: nickname}) if user.nil?
        created = true
      end
      
      # Ricer::Irc::User.current = user
      
      if !user.should_cache? # Not in mem cache yet?
        user.ricer_on_joined_server(server) # We surely joined the server then :)
        if created
          process_event('ricer_on_user_created') # Oh we are brand new!
        end
        process_event('ricer_on_user_loaded') # And we got loaded :)
      end
      
      user
    end
    
    def load_channel(channel_name)
      bot.log_debug "Connect.load_channel(#{channel_name})"
      channel = Ricer::Irc::Channel.where(:name => channel_name, :server_id => server.id).first
      return nil if channel.nil?
      unless (channel.should_cache?)
        process_event('ricer_on_channel_loaded') # And we got loaded :)
      end
      channel
    end
    
    def create_channel(channel_name)
      channel = load_channel(channel_name)
      if channel.nil?
        channel = Ricer::Irc::Channel.create!({server_id:server.id ,name:channel_name})
        process_event('ricer_on_channel_created') # Oh we are brand new!
        process_event('ricer_on_channel_loaded') # And we got loaded :)
      end
      channel
    end
    
  end
end
