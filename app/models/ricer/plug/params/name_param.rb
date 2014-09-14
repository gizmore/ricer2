module Ricer::Plug::Params
  class NameParam < Base

    def convert_in!(input, message)

      min = 3
      max = 32
      input =~ Regexp.new("^[a-z][#{NamedId.allowed}]{#{min-1},#{max-1}}$", true)
      failed_input if input.nil?
      input

    end

    def convert_out!(value, message)
      value
    end
    
  end
end
