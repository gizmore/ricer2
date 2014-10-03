require "socket"
require "openssl"
require "thread"
###
### Raw TCP Connections (thx dloser)
###
module Ricer::Plugins::Netcat
  class Tcp < Ricer::Net::Connection

    def netcat
      get_plugin('Netcat/Netcat')
    end
    
    def connect!
      @connected = false
      begin
        @listener = server.ssl? ? connect_ssl! : connect_tcp!
        @connected = true
        server.started_up = true; server.online = true;
        server.save!
        Ricer::Thread.execute {
          mainloop
        }
        true
      rescue StandardError => e
        bot.log_exception(e)
        false
      end
    end
    
    def connect_tcp!
      bot.log_debug("Netcat connector listen on port #{server.port}")
      TCPServer.new(server.port)
    end

    def connect_ssl!
      bot.log_debug("Netcat connector listen with SSL on port #{server.port}")
      netcat = self.netcat
      listener = TCPServer.new(server.port)
      sslContext = OpenSSL::SSL::SSLContext.new
      sslContext.cert = OpenSSL::X509::Certificate.new(File.open(netcat.public_key_path))
      sslContext.key = OpenSSL::PKey::RSA.new(File.open(netcat.private_key_path))
      sslServer = OpenSSL::SSL::SSLServer.new(listener, sslContext)
    end
    
    def disconnect!
      @connected = false
      if @listener
        @listener.close
        @listener = nil
      end
    end
    
    def mainloop
      begin
        loop {
          NetcatSocket.new(self, @listener.accept)
        }
      rescue StandardError => e
        bot.log_exception(e)
        disconnect!
      end
    end
    
    ####
    ####
    ####
    # def send_raw(message, line); send_line(message.reply_text(line)); end
    # def send_pong(message, ping); send_line(message.reply_text("PONG #{ping}")); end
    # def send_join(message, channelname); send_line(message.reply_text("JOIN #{channelname}")); end
    # def send_part(message, channelname); send_line(message.reply_text("PART #{channelname}")); end
    def send_quit(message, quitmessage); send_to_all(message.reply_text("404: QUIT=#{quitmessage}")); end
    def send_action(message, text); send_line(message.reply_text("*** #{text}")); end
    def send_notice(message, text); send_line(message.reply_text(text)); end
    def send_privmsg(message, text); send_line(message.reply_text(text)); end
    
    def send_line(message)
      send_to(message.reply_target, message.reply_data)
    end

    def send_to(user, text)
      begin
        user.instance_variable_get(:@ricer_netcat_socket).write(text) and return true
      rescue StandardError => e
        bot.log_exception(e) and return false
      end
    end
    
    def send_to_all(message)
      server.users.online.each{|user| send_to(user, message.reply_data) }
    end
    
  end
end
