module Ricer::Plug::Params
  class ServerUrlParam < Base

    def convert_in!(input, message)
      uri = URI(input)||failed_input
      failed_input unless ['irc', 'ircs'].include?(uri.scheme)
      input
    end

    def convert_out!(value, message)
      value.plugin_name
    end
    
  end
end