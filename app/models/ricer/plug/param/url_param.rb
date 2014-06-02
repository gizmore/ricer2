module Ricer::Plug::Param
  class UrlParam < Base

    def self.get_arg(server, arg, message)
      uri = URI(arg)
      return nil if uri.scheme.nil?
      arg
    end
    
  end
end