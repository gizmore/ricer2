module Ricer::Plug::Param
  class NameParam < Base

    def self.get_arg(server, arg, message)
      
      min = 3
      max = 32
      arg =~ Regexp.new("^[a-z][#{NamedId.allowed}]{#{min-1},#{max-1}}$", true)
      arg

    end
    
  end
end
