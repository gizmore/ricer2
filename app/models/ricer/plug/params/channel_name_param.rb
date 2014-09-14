module Ricer::Plug::Params
  class ChannelNameParam < Base

    def convert_in!(input, message)
      failed_input unless Ricer::Irc::Lib.instance.channelname_valid?(input)
      input
    end
    
    def convert_out!(value, message)
      value
    end
    
  end
end
