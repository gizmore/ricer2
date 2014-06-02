module Ricer::Irc::Mode
  class ModeData
    
    SERVERS = {
      :inspircd => /inspirc/i,
      :generic => '',
    }
    
    PERMISSIONS = {
      :generic => {
        '+' => Ricer::Irc::Permission::VOICE,
      }
    }
    
    USERMODES = {
      :generic => {
        
      }
    }
    
  end
end