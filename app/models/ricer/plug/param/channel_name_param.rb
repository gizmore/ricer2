module Ricer::Plug::Param
  class ChannelNameParam < Base

    def self.get_arg(server, arg, message)
      
      lib.channelname_valid?(arg) ? arg : nil

    end
    
  end
end
