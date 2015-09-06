module Ricer::Plug::Params
  class ChannelParam < TargetParam
    
    DEFAULT_OPTIONS ||= { online: nil, multiple: '0', channels: '1', users: '0', connectors: '*' }
    
    def default_options; DEFAULT_OPTIONS;  end
    
  end
end
