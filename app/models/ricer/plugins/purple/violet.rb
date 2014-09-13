module Ricer::Plugins::Purple
  class Violet < Ricer::Net::Connection

    def fake_message; Ricer::Net::Message.fake_message(server); end
    
    def nickname; server.nickname.nickname; end
    def username; server.nickname.username; end
    def password; server.nickname.password; end
    
    def protocol; raise "You have to override Violet#protocol for a libpurple connector."; end
    
    def purple; @@purple ||= bot.get_plugin('Purple/Purple'); end
    
    def connect!
      @account = PurpleRuby.login(protocol, username, password)
      purple.add_purple_server(@account, server)
      @connected = true
      Thread.kill(Thread.current)
      true
#      @account.set_public_alias(nickname)
    end
    
    def watch_incoming_im(acc, sender, text)
      bot.log_debug("Violet#watch_incoming_im with #{acc.username}, #{sender}, #{text}")
      sender = sender.substr_to('/') || sender # discard anything after '/'
      text = (Hpricot(text)).to_plain_text
      user = create_user(sender)
      message = Ricer::Net::Message.new(text)
      message.sender = user
      message.server = server
      message.prefix = "#{sender}!#{protocol}@libpurple"
      message.command = 'PRIVMSG'
      message.args = [sender, text]
      server.process_event("on_privmsg", message)
      server.process_event("ricer_on_receive", message)
    end

    ##################
    ### Like Ricer ###
    ##################    
    def load_user(nickname); Ricer::Irc::User.where({server_id: server.id, nickname: nickname}).first; end
    def create_user(nickname)

      # Try load or create
      created = false
      user = load_user(nickname)
      if user.nil?
        user, created = Ricer::Irc::User.create!({server_id: server.id, nickname: nickname}), true
      end

      # Set current user in extra thread variable scope :(
      # This is needed as some events might need to know which user to process
      # But there might be no sender / receiver in that event or looping many users
      Ricer::Irc::User.current = user
      
      # Register, login, etc.
      if !user.should_cache? # Not in mem cache yet?
        user.ricer_on_joined_server(server) # We surely joined the server then :)
        #user = user.find(user.id)
        if created
          #byebug
          user.permissions = Ricer::Irc::Permission.by_name(:operator).bit
          user.password = '11111111'
          user.save!
          process_event('ricer_on_user_created') # Oh we are brand new!
        end
        process_event('ricer_on_user_loaded') # And we got loaded :)
        if created
          process_event('ricer_on_user_registered')
        end
        user.login!
        process_event('ricer_on_user_authenticated')
      end
      user
    end
    
    def send_raw(message, line); send_line(message.reply_text(line)); end
    def send_pong(message, ping); send_line(message.reply_text("PONG #{ping}")); end
    def send_join(message, channelname); send_line(message.reply_message("JOIN #{channelname}")); end
    def send_part(message, channelname); send_line(message.reply_text("PART #{channelname}")); end
    def send_quit(message, quitmessage); send_line(message.reply_text("QUIT :#{quitmessage}")); end
    def send_notice(message, text); send_line(message.reply_text(text)); end
    def send_privmsg(message, text); send_line(message.reply_text(text)); end
    def send_action(message, text); send_line(message, "NOTICE #{message.reply_to.name} :\x01", text, "\x01"); end

    def login(message, nickname)
      # send_line(message)
    end
    
    def send_nick(message, nickname)
      # send_line(message)
    end
    
    def authenticate(message, nickname)
      # send_line(message)
    end
    
    
    def send_line(message)
      begin
        return unless message.reply_to.is_a?(Ricer::Irc::User)
        @server.ricer_replies_to(message)
        text = message.reply_data#.gsub("\n", '').gsub("\r", '')
        @account.send_im(message.reply_to.name, text)
 #       @frame.sent
      rescue => e
        bot.log_info("Disconnect from #{server.hostname}: #{e.message}")
        bot.log_exception e
        @connected = false
        disconnect(message)
      end
      nil
    end
    
    # def parse(args)
# 
      # message = Ricer::Net::Message.new(args.join('; '))
#       
      # message.prefix = args[0];
      # message.command = args[1].downcase;
      # message.args = Array(args[2])
# 
      # message
    # end
    
    ### TODO: Pick some naming for the include below: Ricer::Entities???
    ### TODO: Make this an include and let plugins/rice/connect use it
    private
    
    def process_event(event)
      server.process_event(event, fake_message)
    end
    
    def sender_nickname
      
      Ricer::Irc::Nickname.nickname_from_message(@message)      
    end
    
    def load_user(nickname)
      Ricer::Irc::User.where({server_id: server.id, nickname: nickname}).first
    end
#     
    # def create_user(nickname)
# 
      # created = false
      # user = load_user(nickname)
      # if user.nil?
        # user = Ricer::Irc::User.create!({server_id: server.id, nickname: nickname}) if user.nil?
        # created = true
      # end
#       
      # # Set current user in thread variable scope :(
      # # This is needed as some events might need to know which user to process
      # # But there might be no sender / receiver in that event or looping many users
      # Ricer::Irc::User.current = user
#       
      # if !user.should_cache? # Not in mem cache yet?
        # user.ricer_on_joined_server(server) # We surely joined the server then :)
        # #user = user.find(user.id)
        # if created
          # #byebug
          # user.permissions = Ricer::Irc::Permission.by_name(:operator).bit
          # user.password = '11111111'
          # user.save!
          # process_event('ricer_on_user_created') # Oh we are brand new!
        # end
        # process_event('ricer_on_user_loaded') # And we got loaded :)
        # if created
          # process_event('ricer_on_user_registered')
        # end
        # user.login!
        # process_event('ricer_on_user_authenticated')
      # end
#       
      # user
    # end
    
    # def load_channel(channel_name)
      # bot.log_debug "Connect.load_channel(#{channel_name})"
      # channel = Ricer::Irc::Channel.where(:name => channel_name, :server_id => server.id).first
      # return nil if channel.nil?
      # unless (channel.should_cache?)
        # process_event('ricer_on_channel_loaded') # And we got loaded :)
      # end
      # channel
    # end
#     
    # def create_channel(channel_name)
      # channel = load_channel(channel_name)
      # if channel.nil?
        # channel = Ricer::Irc::Channel.create!({server_id:server.id ,name:channel_name})
        # process_event('ricer_on_channel_created') # Oh we are brand new!
        # process_event('ricer_on_channel_loaded') # And we got loaded :)
      # end
      # channel
    # end
    
    
    

  end
end
