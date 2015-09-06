module Ricer::Plug::Params
  class IntegerParam < Base
    
    INT_MIN ||= -2123123123
    INT_MAX ||= 2123123123

    def default_options
      { min: INT_MIN, max: INT_MAX }
    end
    
    def min
      (options[:min].to_i rescue INT_MIN) or INT_MIN
    end

    def max
      (options[:max].to_i rescue INT_MAX) or INT_MAX
    end
    
    def convert_in!(input, message)
      fail_type unless input.integer?
      input = input.to_i
      min, max = self.min, self.max
      fail_int_between(min, max) unless input.between?(min, max) 
      input
    end
    
    def fail_int_between(min, max)  
      fail(:err_between, min: min, max: max)
    end  

    def convert_out!(value, message)
      value.to_s
    end
    
  end
end
