module Ricer::Plug::Params
  class LanguageParam < Base

    def convert_in!(input, options, message)
      locale = Ricer::Locale.by_iso(input)
      failed_input if locale.nil?
      locale
    end

    def convert_out!(value, options, message)
      value.to_label
    end
    
  end
end
