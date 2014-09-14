module Ricer::Plug::Params
  class UrlParam < Base

    def convert_in!(input, message)
      uri = URI(input)
      failed_input if uri.scheme.nil?
      input
    end
    
    def convert_out!(value, message)
      value
    end
    
  end
end
