module Ricer::Plug::Param
  class DurationParam < Base
    def self.get_arg(server, arg, message)
      arg.numeric? ? arg.to_f : nil 
    end
  end
end
