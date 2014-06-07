module Ricer::Plug::Params
  class DurationParam < Base
    
    def convert_in!(input, options, message)
      arg.numeric? ? arg.to_f : nil 
      
    end
    
    def convert_out!(value, options, message)
      value
    end
    
  end
end
