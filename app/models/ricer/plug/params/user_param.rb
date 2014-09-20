module Ricer::Plug::Params
  class UserParam < TargetParam
    
    def default_options; { online: nil, channels: '0', users: '1', multiple: '0', connectors: '*' }; end
    
  end
end
