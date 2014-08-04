module Ricer::Plugins::Websocket
  class Websocket < Ricer::Net::Connection
    def fake_message; Ricer::Net::Message.fake_message(server); end
    def connect!
      @connected = true
      EM.run {
        
        EM::WebSocket.run(:host => server.hostname, :port => server.port) do |ws|
          ws.onopen { |handshake|
            puts "WebSocket connection open"
          }
          ws.onclose {
            puts "Connection closed"
            if ws.instance_variable_defined?(:@ricer_user)
              user = ws.instance_variable_remove(:@ricer_user)
              xlin_logout(user, message)
            end
          }
          ws.onmessage { |msg|
            
            message = Ricer::Net::Message.new(msg)
            
            if ws.instance_variable_defined?(:@ricer_user)
              user = ws.instance_variable_get(:@ricer_user)
              message.sender = user
#              message.receiver = server
              message.server = server
              message.prefix = 'gizmore!gizmore@hostname'
              message.command = 'PRIVMSG'
              message.args = [user.nickname, msg]
              server.process_event("on_privmsg", message)
              server.process_event("ricer_on_receive", message)
            else
              # only XLIN
              if msg.start_with?('XLIN ')
                args = msg.split(' ')
                user = websocket_xlin(args[1], args[2], message)
                if user.nil?
                  ws.send('403: Auth failed')
                else
                  ws.instance_variable_set(:@ricer_user, user)
                  user.instance_variable_set(:@websocket, ws)
                  ws.send('200: OK!')
                end
              else
                ws.send('401: Not logged in!')
              end
            end
          }
        end
      }      
    end
    
    def xlin_logout(user, message)
      user.logout!
      server.process_event('ricer_on_user_logged_out', message)
      user.ricer_on_parted_server(server)
    end
    
    def load_user(nickname)
      Ricer::Irc::User.where({server_id: server.id, nickname: nickname}).first
    end
    
    def websocket_xlin(nickname, password, message)

      created = false
      user = load_user(nickname)
      if user.nil?
        user = Ricer::Irc::User.create!({
          server_id: server.id,
          nickname: nickname,
          password: password,
          permissions: Ricer::Irc::Permission.by_name(:operator).bit,
        })
        created = true
      else
        if !user.authenticate!(password)
          return nil
        end
      end
      
      # Set current user in thread variable scope :(
      # This is needed as some events might need to know which user to process
      # But there might be no sender / receiver in that event or looping many users
      Ricer::Irc::User.current = user
      
      if created
        server.process_event('ricer_on_user_created', message) # Oh we are brand new!
      end

      user.ricer_on_joined_server(server) # We surely joined the server then :)
      
      server.process_event('ricer_on_user_loaded', message) # And we got loaded :)

      if created
        server.process_event('ricer_on_user_registered', message)
      end
      user.login!
      server.process_event('ricer_on_user_authenticated', message)
      user
    end
    
    ####
    ####
    ####
    
    def send_raw(message, line); send_line(message.reply_text(line)); end
    def send_pong(message, ping); send_line(message.reply_text("PONG #{ping}")); end
    def send_join(message, channelname); send_line(message.reply_message("JOIN #{channelname}")); end
    def send_part(message, channelname); send_line(message.reply_text("PART #{channelname}")); end
    def send_quit(message, quitmessage); send_to_all(message.reply_text("QUIT :#{quitmessage}")); end
    def send_notice(message, text); send_line(message.reply_text(text)); end
    def send_privmsg(message, text); send_line(message.reply_text(text)); end
    def send_action(message, text); send_line(message, "NOTICE #{message.reply_to.name} :\x01", text, "\x01"); end
    
    def send_to_all(message)
      Ricer::Irc::User.where(:server_id => server.id).online.each do |user|
        ws = user.instance_variable_get(:@websocket)
        ws.send(message.reply_data)
      end
    end
    
    def send_line(message)
      ws = message.sender.instance_variable_get(:@websocket)
      ws.send(message.reply_data)
    end
    
  end
end
