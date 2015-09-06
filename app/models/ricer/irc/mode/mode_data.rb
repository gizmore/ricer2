module Ricer::Irc::Mode
  class ModeData

    include Ricer::Base::Base
    extend  Ricer::Base::BaseExtend
    
    BAN ||= 'b'
    MODERATED ||= 'm'
    USER_INVISBLE ||= 'i'
    CHANNEL_INVISIBLE ||= 'i'

    UNKNOWN_K ||= 'k'
    UNKNOWN_L ||= 'l'
    UNKNOWN_N ||= 'n'
    UNKNOWN_O ||= 'o'
    UNKNOWN_P ||= 'p'
    UNKNOWN_S ||= 's'
    UNKNOWN_T ||= 't'
    UNKNOWN_V ||= 'v'
    UNKNOWN_W ||= 'w'
   
    
    SERVERS ||= {
      :inspircd => /inspirc/i,
      :generic => '',
    }
    
    PERMISSIONS ||= {
      :generic => {
        '+' => Ricer::Irc::Permission::VOICE,
        '%' => Ricer::Irc::Permission::HALFOP,
        '@' => Ricer::Irc::Permission::OPERATOR,
        '~' => Ricer::Irc::Permission::OWNER,
        '!' => Ricer::Irc::Permission::IRCOP,
      }
    }
    
    PERMISSION_MAP ||= {
      :generic => {
        'v' => '+',
        'h' => '%',
        'o' => '@',
      }
    }
    
    USERMODES ||= {
      :generic => {
        'i' => USER_INVISBLE,
        'o' => UNKNOWN_O,
        's' => UNKNOWN_S,
        'w' => UNKNOWN_W,
      }
    }

    CHANMODES ||= {
      :generic => {
        'b' => BAN,
        'i' => CHANNEL_INVISIBLE,
        'k' => UNKNOWN_K,
        'l' => UNKNOWN_L,
        'm' => MODERATED,
        'n' => UNKNOWN_N,
        'o' => UNKNOWN_O,
        'p' => UNKNOWN_P,
        's' => UNKNOWN_S,
        't' => UNKNOWN_T,
        'v' => UNKNOWN_V,
      }
    }
    
    def self.detecteds; @@detected ||= {}; end
    def self.detected(server); detecteds[server] ||= ServerOptions.new(server);  end
    def self.current; detected(current_message.server); end
    def self.current_ircd; current.ircd; end
    def self.permmodes; PERMISSIONS[current_ircd] || PERMISSIONS[:generic]; end
    def self.perm_maps; PERMISSION_MAP[current_ircd] || PERMISSION_MAP[:generic]; end
    def self.usermodes; USERMODES[current_ircd] || USERMODES[:generic]; end
    def self.chanmodes; CHANMODES[current_ircd] || CHANMODES[:generic]; end
    
    def self.detect_server(server, signature)
      bot.log_debug("ModeData::detect_server(#{server.displayname}): #{signature}")
      detected = self.detected(server).clear
      SERVERS.each do |ircd, pattern|
        if pattern.match(signature)
          detected.ircd = ircd
          break
        end
      end
      detected.set_permissions(permmodes, perm_maps)
      # bot.log_debug("ModeData::detect_server(#{server.displayname}) DETECTED: #{detected.inspect}")
      detected
    end

    # irc.giz.org << :irc.giz.org 004 ricer irc.giz.org InspIRCd-2.0 iosw biklmnopstv bklov
    def self.detect_004(server, args)
      bot.log_debug("ModeData::detect_004(#{server.displayname}): #{args.inspect}")
      detect_usermodes(server, args[3])
      detect_chanmodes(server, args[4])
      detect_cargmodes(server, args[5])
    end
    
    # irc.giz.org << :irc.giz.org 005 ricer AWAYLEN=200 CASEMAPPING=rfc1459 CHANMODES=b,k,l,imnpst CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU FNC KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=20 MAXPARA=32 :are supported by this server
    # irc.giz.org << :irc.giz.org 005 ricer MAXTARGETS=20 MODES=20 NETWORK=lambdev NICKLEN=31 PREFIX=(ov)@+ STATUSMSG=@+ TOPICLEN=307 VBANLIST WALLCHOPS WALLVOICES :are supported by this server
    def self.detect_005(server, args)
      detected(server).parse_config(args[1..-2])
    end
    
    def self.detect_usermodes(server, usermodes)
      usermodes.each_char do |c|
        detected(server).add_usermode(c, self.usermodes[c])
      end
    end

    def self.detect_chanmodes(server, chanmodes)
      chanmodes.each_char do |c|
        detected(server).add_chanmode(c, self.chanmodes[c])
      end
    end 

    def self.detect_cargmodes(server, chanmodes)
      if chanmodes
        chanmodes.each_char do |c|
          detected(server).add_cargmode(c)
        end
      end
    end
    
  end
end
