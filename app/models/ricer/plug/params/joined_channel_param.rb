module Ricer::Plug::Params
  class JoinedChannelParam < ChannelParam

    def convert_in!(input, options, message)
      options[:online] = true
      super(input, options, message)
    end
    
  end
end
