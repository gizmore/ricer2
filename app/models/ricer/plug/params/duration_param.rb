module Ricer::Plug::Params
  class DurationParam < Base
    
    def convert_in!(input, options, message)
      input.numeric? ? input.to_f : failed_input 
    end
    
    def convert_out!(value, options, message)
      value
    end
    
  end
end
