module Ricer::Plugins::Purple
  class Purple < Ricer::Net::Connection

    #Ruburple::init

    def fake_message; Ricer::Net::Message.fake_message(server); end
    
    def username; server.nickname.nickname; end
    def password; server.nickname.password; end
    
    def connect!
      @received = []

      @protocol = Ruburple::get_protocol(purple_protocol_symbol)
      if @protocol.nil?
        throw Ricer::ExecutionException.new("LibPurple/Ruburple does not speak #{purple_protocol_symbol}")        
      end
      byebug


      @account = @protocol.get_account(username, password)
      @connected = true
      
      # Make buddies online
      @account.buddies.each do |buddy|
        user = create_user(buddy.name)
      end
      
      # Ruburple.class_variable_get(:@@events).each do |event, bla|
        # Ruburple::subscribe(event) do |account, sender, message, conversation, flags|
          # puts account.inspect
          # puts sender.inspect
          # puts message.inspect
          # puts conversation.inspect
          # puts flags.inspect
        # end
#         
      # end
      Ruburple::subscribe(:account_authorization_requested) do |account, sender, message, conversation, flags|
        byebug
        if account.uid == @account.uid
          purple_add_buddy(account, sender, message, conversation, flags)
        end
      end
      
      Ruburple::subscribe(:received_im_msg) do |account, sender, message, conversation, flags|
        if account.uid == @account.uid
          purple_receive(sender, message, conversation, flags)
        end
      end 

      # Ruburple::subscribe(:received_chat_msg) do |account, sender, message, conversation, flags|
        # if account.uid == @account.uid
          # purple_receive(sender, message, conversation, flags)
        # end
      # end 

      
      @account.connect
      
      # Ruburple.class_variable_get(:@@events).each do |event, pointer|
        # Ruburple::subscribe(event) do |*args|
          # byebug
          # puts args.inspect 
        # end
      # end
      

      
      return true
    end
    
    def disconnect(message); disconnect!(message||fake_message) if @ricer; end
    
    def disconnect!(message)
      @account = nil
    end
    

    def purple_add_buddy(sender, message, conversation, flags)
      byebug
      puts "HELLO"
    end
    
    def purple_receive(sender, message, conversation, flags)
      @received.push([
        sender,
        "PRIVMSG",
        [@account.uid, text_line(message)]
      ])
    end
    
    def text_line(message)
      message
    end
    
    def get_line
      while true
        message = @received.shift
        return message unless message.nil?
        sleep 0.05
      end
    end
    
    
    
    
    ### ---- RICER STYLE ---- ###
    
    
    
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
        @account.connection.send_im(message.reply_to.name, text)
 #       @frame.sent
      rescue => e
        bot.log_info("Disconnect from #{server.hostname}: #{e.message}")
        bot.log_exception e
        @connected = false
        disconnect(message)
      end
      nil
    end
    
    def parse(args)

      message = Ricer::Net::Message.new(args.join('; '))
      
      message.prefix = args[0];
      message.command = args[1].downcase;
      message.args = Array(args[2])

      message
    end
    
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
    
    def create_user(nickname)

      created = false
      user = load_user(nickname)
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
