module Ricer::Plug::Params
  class ChannelNameParam < Base

    def convert_in!(input, options, message)
      failed_input unless Ricer::Irc::Lib.instance.channelname_valid?(input)
      input
    end
    
    def convert_out!(value, options, message)
      value
    end
    
  end
end
