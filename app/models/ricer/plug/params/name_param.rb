module Ricer::Plug::Params
  class NameParam < Base

    def convert_in!(input, options, message)

      min = 3
      max = 32
      arg =~ Regexp.new("^[a-z][#{NamedId.allowed}]{#{min-1},#{max-1}}$", true)
      failed_input if arg.nil?
      arg

    end

    def convert_out!(value, options, message)
      value
    end
    
  end
end
