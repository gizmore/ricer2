module Ricer::Plug::Param
  class IdParam < Base
    def self.get_arg(server, arg, message)
      return (arg.integer? && (arg.to_i > 0)) ? arg.to_i : nil
    end
  end
end
