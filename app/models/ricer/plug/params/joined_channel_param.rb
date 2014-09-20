module Ricer::Plug::Params
  class JoinedChannelParam < ChannelParam
    
    DEFAULT_OPTIONS = { online: '1', channels: '1', users: '0', connectors: '*', multiple: '0' }
    
    def default_options; DEFAULT_OPTIONS; end
    
  end
end
