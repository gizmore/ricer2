module Ricer::Plug::Params
  class PasswordParam < Base
    def convert_in!(input, message)
      input
    end
    def convert_out!(value, message)
      "$HASH$"
    end
  end
end
