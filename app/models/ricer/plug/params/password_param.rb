module Ricer::Plug::Params
  class PasswordParam < Base
    def convert_in!(input, message)
      Ricer::Plug::Password.new(input)
    end
    def convert_out!(value, message)
      "$HASH$"
    end
  end
end
