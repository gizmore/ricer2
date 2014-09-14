module Ricer::Plug::Params
  class VariableParam < StringParam
    def convert_in!(input, message)
      super(input, message).to_sym
    end
  end
end
