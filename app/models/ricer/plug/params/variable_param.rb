module Ricer::Plug::Params
  class VariableParam < StringParam
    def convert_in!(input, options, message)
      super(input, options, message).to_sym
    end
  end
end
