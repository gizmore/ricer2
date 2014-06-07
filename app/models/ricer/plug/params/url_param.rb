module Ricer::Plug::Params
  class UrlParam < Base

    def convert_in!(input, options, message)
      uri = URI(arg)
      failed_input if uri.scheme.nil?
      input
    end
    
    def convert_out!(value, options, message)
      value
    end
    
  end
end