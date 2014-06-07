module Ricer::Plug::Params
  class PasswordParam < Base
    def convert_in!(input, options, message)
      input
    end
    def convert_out!(value, options, message)
      "$HASH$"
    end
  end
end
