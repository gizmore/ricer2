module Ricer::Plug::Params
  class IntegerParam < Base
    
    INT_MIN = -2123123123
    INT_MAX = 2123123123
    
    def min(options)
      options[:min].nil? || options[:min].is_not_a?(Integer) ? INT_MIN : options[:min]
    end
    def max(options)
      options[:max].nil? || options[:max].is_not_a?(Integer) ? INT_MAX : options[:max]
    end
    
    def convert_in!(input, options, message)
      unless input.integer?
        fail_type(input, 'Integer')
      end
      input = input.to_i
      min,max = self.min(options), self.max(options)
      fail_int_between(min, max) unless input.between?(min, max) 
      input
    end
    
    def fail_int_between(min, max)  
      fail(:err_between, min, max)
    end  

    def convert_out!(value, options, message)
      value.to_s
    end
    
  end
end
