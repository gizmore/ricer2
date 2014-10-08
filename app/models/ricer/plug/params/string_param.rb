module Ricer::Plug::Params
  class StringParam < Base
    
    def default_options; { min: 1, max: 65535 }; end

    def convert_in!(input, message)
      min, max = min_length, max_length
      fail(:err_too_short, min: min, max: max) if min != nil && input.length < min
      fail(:err_too_long,  min: min, max: max) if max != nil && input.length > max
      input.to_s
    end
    
    def convert_out!(value, message)
      failed_output unless value.is_a?(String)
      value
    end
    
    def min_length
      options[:min].to_i.clamp(1, 10.megabytes) rescue 1
    end

    def max_length
      options[:max].to_i.clamp(min_length, 10.megabytes) rescue 10.megabytes
    end
    
  end
end
