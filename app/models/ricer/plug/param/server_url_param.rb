module Ricer::Plug::Param
  class ServerUrlParam < Base

    def self.get_arg(server, arg, message)
      uri = URI(arg)
      return nil unless ['irc', 'ircs'].include?(uri.scheme)
      arg
    end
    
  end
end