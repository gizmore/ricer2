module Ricer::Plug::Params
  class LanguageParam < Base

    def convert_in!(input, message)
      Ricer::Locale.by_iso(input) or failed_input
    end

    def convert_out!(value, message)
      value.to_label
    end
    
  end
end
