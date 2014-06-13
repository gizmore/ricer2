module Ricer::Plug::Params
  class StringParam < Base

    def convert_in!(input, options, message)
      min,max = min_length(options),max_length(options)
      fail(:err_too_short, min, max) if min != nil && input.length < min
      fail(:err_too_long, min, max) if max != nil && input.length > max
      input
    end
    
    def convert_out!(value, options, message)
      failed_output unless value.is_a?(String)
      value
    end
    
    def min_length(options)
      return nil if options[:min].nil?
      options[:min].to_i
    end
    def max_length(options)
      return nil if options[:max].nil?
      options[:max].to_i
    end
    
  end
end
