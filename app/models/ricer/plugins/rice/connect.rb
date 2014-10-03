###
### The core IRC plugin that sets up users and channels when receiving events
###
module Ricer::Plugins::Rice
  class Connect < Ricer::Plugin
    
    connector_is :irc
    has_priority 1 # We have to be called first!
    
    def core_plugin?; true; end
    
    def ricer_on_server_handshake
      bot.log_debug "Ricer::Plugins::Rice::Connect.ricer_on_server_handshake()"
#      server.next_nickname
      server.login(current_message)
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
      server.authenticate(current_message)
    end


    # irc.giz.org << :irc.giz.org 002 ricer :Your host is irc.giz.org, running version InspIRCd-2.0
    def on_002
      Ricer::Irc::Mode::ModeData.detect_server(server, args[1])
    end
    def on_004
      Ricer::Irc::Mode::ModeData.detect_004(server, args)
    end
    
    def on_nick
      old_user = create_user(sender_nickname)
      new_user = create_user(args[0])
      current_message.sender = new_user
      Ricer::Irc::Chanperm.where(:user_id => old_user.id, :online => true).each do |chanperm|
        new_user.ricer_on_joined_channel(chanperm.channel)
      end
    end
    
    def on_notice
      on_privmsg unless current_message.prefix.index('!').nil? rescue nil
    end

    def on_privmsg
      # Every privmsg origins from a user
      current_message.sender = create_user(sender_nickname)
      # And maybe belongs to a channel
      current_message.receiver = server.load_channel(current_message.args[0])
      # Set the hostmask for security reasons
      current_message.sender.hostmask = current_message.hostmask
      # Else it belongs to bot itself
#     current_message.receiver = bot if message.receiver.nil?
    end
    
    def on_ping
      server.connection.send_pong(current_message, args[0])
    end
    
    def on_error
      server.disconnect!(current_message)
    end
    
    def on_quit
      current_message.sender = create_user(sender_nickname)
      unless current_message.is_ricer?
        current_message.sender.ricer_on_parted_server(server)
      else
        server.disconnect!(current_message)
      end
    end
    
    def on_join
      current_message.sender = create_user(sender_nickname)
      current_message.receiver = channel = create_channel(args[0])
      user.ricer_on_joined_channel(channel)
      process_event('ricer_on_user_joined') unless ricer_itself?
    end
    
    def on_part
      current_message.sender = create_user(sender_nickname)
      current_message.receiver = channel = create_channel(args[0])
      if current_message.is_ricer?
        channel.ricer_on_part
        Ricer::Irc::Chanperm.where(:channel_id => channel.id).update_all(:online => false)
      else
        current_message.sender.ricer_on_parted_channel(channel)
      end
    end
    
    def on_kick
      current_message.sender = create_user(sender_nickname)
      current_message.receiver = channel = create_channel(args[0])
      kicked_user = create_user(args[1])
      if (kicked_user.is_ricer?)
        channel.ricer_on_part
        Ricer::Irc::Chanperm.where(:channel_id => channel.id).update_all(:online => false)
      else
        kicked_user.ricer_on_parted_channel(channel)
      end
    end
    
    def on_353
      current_message.receiver = channel = create_channel(args[2])
      args[3].split(' ').each do |username|
        username.strip!
        unless username.empty?
          user = create_user(Ricer::Irc::Nickname.nickname_from_prefix(username))
          user.ricer_on_joined_channel(channel, Ricer::Irc::Permission.bits_from_nickname(username))
          user.chanperm_for(channel).chanmode.set_mode(mode_symbols_from_username(username))
        end
      end
    end
    
    def on_mode
      if (channel = server.load_channel(args[0]))
        on_mode_channel(channel)
      elsif (current_message.sender = server.load_user(args[0]))
        on_mode_user(current_message.sender)
      end
    end
    
    # DOminiOn.german-elite.net << :gizmore!~gizmore@www.wechall.net MODE #shadowlamb +o icore4711
    def on_mode_channel(channel)
      bot.log_debug("Connect#on_mode_channel()")
      nextuser,i = 2,0
      positive = true
      maxmodes = args[1].length
      while i < maxmodes
        if args[1][i] == '+'
          positive = true
        elsif args[1][i] == '-'
          positive = false
        else
          mode = args[1][i]
          user = server.load_user(args[nextuser])
          nextuser += 1
          if (user)
            chanmode = user.chanperm_for(channel).chanmode
            if positive; chanmode.set_mode(mode)
            else; chanmode.remove_mode(mode); end
          end
        end
        i += 1
      end
    end

    def on_mode_user(user)
      
    end
    
    def mode_symbols_from_username(username)
      all_symbols = Ricer::Irc::Permission.all_symbols
      regular_exp = Regexp.new("[^#{all_symbols}]")
      username.gsub(regular_exp, '')
    end
    
    def on_433
      server.next_nickname
      server.send_nick(current_message)
    end
    
    private
    
    def sender_nickname
      Ricer::Irc::Nickname.nickname_from_message(current_message)      
    end
    
    # def load_user(nickname)
      # Ricer::Irc::User.where({server_id: server.id, nickname: nickname}).first
    # end
    
    def create_user(nickname)
      
      created = false
      user = server.load_user(nickname)
      if user.nil?
        user = Ricer::Irc::User.create!({server_id: server.id, nickname: nickname}) if user.nil?
        created = true
      end
      
      # Set current user in thread variable scope :(
      # This is needed as some events might need to know which user to process
      # But there might be no sender / receiver in that event or looping many users
      Ricer::Irc::User.current = user
      
      if !user.should_cache? # Not in mem cache yet?
        user.ricer_on_joined_server(server) # We surely joined the server then :)
        if created
          process_event('ricer_on_user_created') # Oh we are brand new!
        end
        process_event('ricer_on_user_loaded') # And we got loaded :)
      end
      
      user
    end
    
    # def load_channel(channel_name)
      # # bot.log_debug "Rice/Connect#load_channel(#{channel_name})"
      # channel = server.load_channel(channel_name)
      # channelname_valid?
      # channel = Ricer::Irc::Channel.where(:name => channel_name, :server_id => server.id).first
      # return nil if channel.nil?
      # unless (channel.should_cache?)
      # end
      # channel
    # end
    
    def create_channel(channel_name)
      channel = server.load_channel(channel_name)
      if channel.nil?
        channel = Ricer::Irc::Channel.create!({server_id:server.id ,name:channel_name})
        process_event('ricer_on_channel_created') # Oh we are brand new!
      end
      unless channel.online
        channel.ricer_on_join
        process_event('ricer_on_channel_loaded') # And we got loaded :)
      end
      channel
    end
    
  end
end
