module Ricer::Irc::Mode
  class ServerOptions
    
    attr_reader :permissions, :permiss_map
    
    def initialize(server)
      @server = server
      clear
    end
    
    def clear
      @ircd = :generic;  @capabilites = {}
      @permissions = {}; @permiss_map = {}
      @usermodes   = {}; @chanmodes   = {}; @cargmodes = []
      self
    end
    
    def ircd; @ircd; end
    def ircd=(ircd); @ircd = ircd; end

    # AWAYLEN=200 CASEMAPPING=rfc1459 CHANMODES=b,k,l,imnpst CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU FNC KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=20 MAXPARA=32
    # MAXTARGETS=20 MODES=20 NETWORK=lambdev NICKLEN=31 PREFIX=(ov)@+ STATUSMSG=@+ TOPICLEN=307 VBANLIST WALLCHOPS WALLVOICES
    def parse_config(args)
      args.each do |config|
        key, value = *args.split('=')
        if value.integer?; value = value.to_i
        elsif value.float?; value = value.to_f
        else; value = value.trim; end
        @capabilites[key] = value
      end
      self
    end
    
    def set_permissions(permissions, permission_map)
      @permissions = permissions.clone
      @permiss_map = permission_map
      self
    end

    def add_usermode(char, modeconst)
      @usermodes[char] = modeconst
      self
    end

    def add_chanmode(char, modeconst)
      @chanmodes[char] = modeconst
      self
    end
    
    def add_cargmode(char)
      @cargmodes.push(char) unless @cargmodes.include?(char)
      self
    end
    
  end
end
