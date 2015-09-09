module Ricer::Plug::Params
  class JoinedChannelParam < ChannelParam
    
    def default_options; { online: '1', channels: '1', users: '0', connectors: '*', multiple: '0' }; end
    
  end
end
