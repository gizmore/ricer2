module Ricer::Plug::Params
  class ChannelNameParam < Base

    def convert_in!(input, message)
      Ricer::Irc::Lib.instance.channelname_valid?(input) or failed_input 
      input
    end
    
    def convert_out!(value, message)
      message ?
        value + ":#{message.server.domain}" :
        value
    end
    
  end
end
