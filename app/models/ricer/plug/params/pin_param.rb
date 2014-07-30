module Ricer::Plug::Params
  class PinParam < Base
    
    def convert_in!(input, options, message)
      Ricer::Plug::Pin.new(input)
    end
    
    def convert_out!(pin, options, message)
      pin.to_s
    end

  end
end
