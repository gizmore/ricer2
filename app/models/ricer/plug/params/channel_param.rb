module Ricer::Plug::Params
  class ChannelParam < TargetParam
    
    def default_options; { online: nil, multiple: '0', channels: '1', users: '0', connectors: '*' }; end
    
  end
end
