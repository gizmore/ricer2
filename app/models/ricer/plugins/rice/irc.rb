module Ricer::Plugins::Rice
  class Irc < Ricer::Net::Connection    
  
    MAXLEN = 512
    
    require 'uri'
    require 'socket'
    
    def connect!
      begin
        @queue = {}
        @semaphore ||= Mutex.new
        if server.ssl?
          server.bot.log_info("Connecting via TLS to #{hostname}")
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE unless server.peer_verify
          sock = TCPSocket.new(hostname, port)
          @socket = OpenSSL::SSL::SSLSocket.new(sock, ssl_context)
          @socket.sync = true
          @socket.connect
        else
          server.bot.log_info("Connecting to #{hostname}")
          @socket = TCPSocket.new(hostname, port)
        end
        connected
      rescue => e
        bot.log_exception(e)
      end
    end
    
    def queue_for(user)
      @queue[user]
    end

    def flush_queue_for(user)
      return [] if @queue[user].nil?
      @semaphore.synchronize do
        messages = @queue[user].lines.clone
        @queue[user].flush
        return messages
      end
    end
    
    def connected
      @connected = true
      @frame = Ricer::Net::Queue::Frame.new(server)
      send_queue
      fair_queue
    end
    
    def disconnect(message); disconnect!(message||fake_message) if @socket; end
    
    def get_line; begin; @socket.gets; rescue => e; disconnect(fake_message); end; end
    
    def fake_message; Ricer::Net::Message.fake_message(server); end
    
    def send_raw(message, line); send_queued(message.reply_text(line)); end
    def send_pong(message, ping); send_queued(message.reply_text("PONG #{ping}")); end
    def send_join(message, channelname, password=nil); send_queued(message.reply_message("JOIN #{channelname}#{password ?(' '+password):''}")); end
    def send_part(message, channelname); send_queued(message.reply_text("PART #{channelname}")); end
    def send_quit(message, quitmessage); send_line(message.reply_text("QUIT :#{quitmessage}")) if @connected; end
    def send_notice(message, text); send_splitted(message, "NOTICE #{message.reply_to.name} :#{message.reply_prefix}", text); end
    def send_privmsg(message, text); send_splitted(message, "PRIVMSG #{message.reply_to.name} :#{message.reply_prefix}", text); end
    def send_action(message, text); send_splitted(message, "NOTICE #{message.reply_to.name} :\x01", text, "\x01"); end
    def login(message, nickname)
      server.bot.log_info("Logging in as #{nickname.next_nickname}")
      send_line(message.reply_text("USER #{nickname.username} #{nickname.hostname} #{hostname} :#{nickname.realname}"))
      send_nick(message, nickname)
    end
    
    def send_nick(message, nickname)
      send_line(message.reply_text("NICK #{nickname.next_nickname}"))
      authenticate(message, nickname)
    end
    
    def authenticate(message, nickname)
      send_line(message.reply_text("PRIVMSG NickServ :IDENTIFY #{nickname.password}")) if nickname.can_authenticate?
    end
    
    private
    def disconnect!(message)
      if @connected
        server.bot.log_info("Disconnecting from #{hostname}")
        send_quit(message, 'disconnect!') if @connected
        @semaphore.synchronize do
          @connected = false
          @socket.close
          @socket = nil
        end 
      end
    end
    
    def send_splitted(message, prefix, text, postfix='')
      length = MAXLEN - prefix.length
#      text.scan(Regexp.new(".{1,#{length}}(?:\s|$)|.{1,#{length}}")).map(&:strip).each do |line|
      text.scan(Regexp.new(".{1,#{length}}(?:\s|$)|.{1,#{length}}")).each do |line|
        send_queued(message.reply_message(prefix+line+postfix))
      end
      nil
    end
    
    def send_queued(message)
      to = message.sender
      @semaphore.synchronize do 
        @queue[to] ||= Ricer::Net::Queue::Object.new(to)
        @queue[to].push(message)
      end
      nil
    end
    
    def send_line(message)
      begin
#        bot.log_debug('Irc#send_line: #{message.reply}')
        Thread.current[:ricer_message] = message
        @server.ricer_replies_to(message)
        text = message.reply_data.gsub("\n", '').gsub("\r", '')
        text.force_encoding(message.reply_encoding_iso)
        @socket.write "#{text}\r\n"
        @frame.sent
      rescue => e
        bot.log_info("Disconnect from #{server.hostname}: #{e.message}")
        bot.log_exception e
        @connected = false
        disconnect(message)
      end
      nil
    end
    
    # Thread that reduces penalty for QueueObjects
    def fair_queue
      Ricer::Thread.execute do
        while @connected
          sleep(Ricer::Net::Queue::Frame::SECONDS * 2)
          @semaphore.synchronize do
            @queue.each{|to, queue| queue.reduce_penalty }
          end
        end
      end
    end
    
    # Thread that sends QueueObject lines
    def send_queue
      Ricer::Thread.execute do
        while @connected
          @semaphore.synchronize do 
            @queue = Hash[@queue.sort_by{|to,queue|queue.penalty}]
            @queue.each do |to, queue|
              break if queue.empty? || @frame.exceeded?
              send_line queue.pop
            end
          end
          sleep @frame.sleeptime
        end
      end
    end
    
    ### IRC Message parser
    def parse(line)
      
      line.rtrim!("\r\n")
      
      message = Ricer::Net::Message.new(line)
      
      raw = line
      
      s = 0 # start index
      e = raw.index(' ') # end index
      l = false # Last processed?
      
      # Prefixes start with ':'
      if raw[s] == ':'
        message.prefix = raw[s..e-1]
      else
        e = -1
        message.prefix = nil
      end
      
      # Now the command
      s = e + 1
      e = raw.index(' ', s)
      if e.nil?
        # Which could be the last thing, without any args
        message.command = raw[s..-1].downcase
        return message
      end
      message.command = raw[s..e-1].downcase
      
      args = [];
      s = e + 1
      
      while !(e = raw.index(' ', s)).nil?
        if (raw[s] == ':')
          s = s + 1
          arg = raw[s..-1]
          s = raw.length
          l = true
        else
          arg = raw[s..e-1]
          s = e + 1
        end
        args.push(arg)
      end

      # Last arg
      if l == false
        s = s + 1 if raw[s] == ':'
        args.push(raw[s..-1])
      end
      message.args = args
      return message
    end    
  end
end
