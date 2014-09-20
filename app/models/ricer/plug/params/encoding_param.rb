module Ricer::Plug::Params
  class EncodingParam < Base

    def convert_in!(input, message)
      Ricer::Encoding.by_iso(input) or failed_input
    end

    def convert_out!(encoding, message)
      encoding.to_label
    end
    
  end
end
