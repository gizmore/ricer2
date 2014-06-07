module Ricer::Plug::Params
  class PinParam < Base
    
    def convert_in!(input, options, message)
      input
    end
    def convert_out!(value, options, message)
      value
    end

  end
end
