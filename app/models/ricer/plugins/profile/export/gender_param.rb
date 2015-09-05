module Ricer::Plug::Params
  class GenderParam < Base
    def convert_in!(input, message)
      return 'm' if input == 'm'
      return 'f' if input == 'f'
      input_failed
    end
  end
end
