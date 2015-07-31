module Ricer::Plug::Params
  class LangIsoParam < Base
    
    def convert_in!(input, message)
      if options[:multiple]
        convert_in_multiple!(input, message)
      else
        Ricer::Locale.by_iso(input) or failed_input
      end
    end
    
    def convert_in_multiple!(input, message)
      back = [];
      input.split(',').each do |iso|
        locale = Ricer::Locale.by_iso(input) or failed_input
        back.push(locale)
      end
      back
    end
    
    def convert_out!(lang_iso, message)
      lang_iso.to_s
    end
    
  end
end
