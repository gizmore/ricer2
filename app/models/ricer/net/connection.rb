module Ricer::Net
  class Connection
    
    attr_reader :server
    
    def self.connector_symbol; @_sym ||= name.to_s.rsubstr_from('::').downcase.to_sym; end
    def connector_symbol; self.class.connector_symbol; end
    
    def bot; server.bot; end
    
    def initialize(server); @server = server;  end
    def displayname; connector_symbol.upcase; end
    def connected?; @connected ? true : false; end
    def encrypted?; uri.sheme == 'ircs'; end
    def uri; @_uri ||= URI(@server.url); end
    def hostname; uri.host; end
    def port; uri.port; end

    ##############
    ## Abstract ##
    ##############
    def connect!; stub("connect"); end
    def disconnect; stub("disconnect"); end
    def disconnect!; stub("disconnect!"); end
    def get_line; stub("get_line"); end
    
    def send_messages(message); stub('send_message'); end

    def send_raw(line); stub('send_raw'); end
    def send_pong(ping); stub('send_pong'); end
    def send_join(channelname); stub('send_join'); end
    def send_part(channelname); stub('send_part'); end
    def send_quit(quitmessage); stub('send_quit'); end
    def send_notice(to, text, prefix); stub('send_notice'); end
    def send_privmsg(to, text, prefix); stub('send_privmsg'); end
    def send_nick(nickname); stub('send_nick'); end

    def login(nickname); stub('login'); end
    def authenticate(nickname); stub('authenticate'); end
    def parse(line); stub('parse'); end

    ############
    ## Helper ##
    ############
    def get_message
      line = get_line
      bot.puts_mutex.synchronize do
        puts "#{hostname} << #{line}"
      end
      parse(line) unless line.nil?
    end
 
    private
    def stub(methodname)
      throw "#{self.class.name} does not handle 'def #{methodname}'"
    end
    
  end
end
