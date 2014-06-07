module Ricer::Plug::Params
  class IntegerParam < Base
    
    INT_MIN = -2123123123
    INT_MAX = 2123123123
    
    def self.min(options)
      options[:min].nil? || options[:min].is_not_a?(Integer) ? INT_MIN : options[:min]
    end
    def self.max(options)
      options[:max].nil? || options[:max].is_not_a?(Integer) ? INT_MAX : options[:max]
    end
    
    def convert_in!(input, options, message)
      unless arg.integer?
        fail_type(arg, 'Integer')
      end
      arg = arg.to_i
      fail_int_between(min, max) unless arg.between?(min, max) 
      return arg
    end
    
    def fail_int_between(min, max)  
      fail(:err_between, min, max)
    end  

    def convert_out!(value, options, message)
      value.to_s
    end
    
  end
end
