module Ricer::Plugins::Netcat
  class NetcatSocket
    
    include Ricer::Base::Base
    
    IP_TRIES = {}
    IP_COOLDOWN = 10
    
    def initialize(connection, socket)
      @user = nil
      @server = connection.server
      @ip = socket.addr[3]
      @connection, @socket = connection, socket
      @mutex = Mutex.new
      IP_TRIES[@ip] = 0
      mainloop
    end
    
    def mainloop
      Ricer::Thread.execute {
        begin
          bot.log_info("TCP Client #{@ip} connected.")
          write("201 CREATED CONNECTION WITH Ricer2.0a. WELCOME #{@ip}!")
          while line = @socket.gets
            raw_message(line.rtrim!)
          end
          write("410 CONNECTION CLOSED.")
          bot.log_info("TCP Client #{@ip} disconnected.")
        rescue StandardError => e
          bot.log_exception(e)
        ensure
          xlin_logout
        end
      }
    end
    
    def write(text)
      bot.log_puts("[TCP] >> #{text}")
      @mutex.synchronize {
        @socket.puts(text) rescue xlin_logout
      }
      true
    end
    
    def netcat_usermask(user=nil)
      (user||@user).nickname + "!#{@ip}@nc-ricer2"
    end
    
    def raw_message(msg)

      bot.log_puts("[TCP] << #{@ip} :#{msg}")
      message = Ricer::Net::Message.new(msg)
      
      if @user
        @user.hostmask = message.prefix = netcat_usermask
        Ricer::Irc::User.current = @user
        message.sender  = @user
#       message.receiver= server
        message.server  = @server
#        message.prefix  = "#{@user}!#{@ip}@ncr2"
        message.command = "PRIVMSG"
        message.args = [@user.nickname, msg]
        @server.process_event("on_privmsg", message)
        @server.process_event("ricer_on_receive", message)
      else
        xlin, username, password = *msg.split(' ')
        if (xlin && (xlin.downcase == 'xlin')) && username && password
          @user = xlin_login(username, password, message)
        else
          write('401: XLIN MISSING - You are not logged in.')
        end
      end
    end
    
    def xlin_logout
      bot.log_debug("NCSocket#xlin_logout")
      if @user
        @user.ricer_on_parted_server(@server)
        @server.process_event('ricer_on_user_logged_out', @server.fake_message)
        @user.remove_instance_variable(:@ricer_netcat_socket)
        @user.logout!
        @user = nil
      end
      true
    end
    
    def xlin_auth_left
      IP_COOLDOWN - (Time.now.to_i - IP_TRIES[@ip])
    end
    
    def xlin_auth(user, password)
      if (left = xlin_auth_left) > 0
        write("402: BRUTEFORCE PROTECTION. WAIT #{left}s")
      elsif !user.password_matches?(password)
        write("403: AUTHENTICATION FAILURE.")
      elsif @user.instance_variable_defined?(:@ricer_netcat_socket)
        write("406: GHOST USER")
      else
        write('200: AUTHENTICATED!')
        return true
      end
      IP_TRIES[@ip] = Time.now.to_i
      false
    end
    
    def xlin_login(nickname, password, message)
      created = false
      user = @server.load_user(nickname)
      if user.nil?
        user = Ricer::Irc::User.create!({
          server_id: @server.id,
          nickname: nickname,
          password: password,
          permissions: Ricer::Irc::Permission::AUTHENTICATED.bit,
        })
        created = true
        write('200: REGISTERED!')
      else
        return nil unless xlin_auth(user, password)
      end
      
      # Connect user with this socket
      user.instance_variable_set(:@ricer_netcat_socket, self)

      # Setup his host mask
      user.hostmask = netcat_usermask(user)
      
      # Set current user in thread variable scope :(
      # This is needed as some events might need to know which user to process
      # But there might be no sender / receiver in that event or looping many users
      Ricer::Irc::User.current = user
      
      ### Everything´s prepared to fire events..
      # Created
      if created
        @server.process_event('ricer_on_user_created', message) # Oh we are brand new!
      end
      # Joined
      user.ricer_on_joined_server(@server) # We surely joined the server then :)
      # Loaded
      @server.process_event('ricer_on_user_loaded', message) # And we got loaded :)
      # Registered
      if created
        @server.process_event('ricer_on_user_registered', message)
      end
      # Authenticated
      user.login!
      @server.process_event('ricer_on_user_authenticated', message)
      # K.Thx.Nice
      user
    end
        
  end
end
