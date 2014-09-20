module Ricer::Plug::Params
  class ServerUrlParam < UrlParam
    
    def schemes
      ['irc', 'ircs']
    end
    
  end
end