module Ricer::Plug::Params
  class StaticParam < Base
    
    def expected_static_text(message)
      message.plugin.t("static_param_#{options[:text]}".to_sym) rescue options[:text]
    end
    
    def convert_in!(input, message)
      failed_input unless input == options[:text] || input == expected_static_text(message) 
      input
    end
    
    def convert_out!(value, message)
      value
    end
    
  end
end
