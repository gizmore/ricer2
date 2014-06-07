module Ricer::Plug::Params
  class VariableParam < Base
    def self.get_arg(server, arg, message)
      arg.to_sym
    end
  end
end
