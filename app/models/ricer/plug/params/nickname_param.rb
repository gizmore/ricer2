module Ricer::Plug::Params
  class NicknameParam < Base

    def convert_in!(value, message)
      failed_input unless Ricer::Irc::Lib.instance.nickname_valid?(value)
      value 
    end

    def convert_out!(value, message)
      value
    end

  end
end
