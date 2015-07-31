module Ricer::Plug::Params
  class LangIsoParam < Base
    
    def is_multiple?
      options[:multiple] == "1"
    end
    
    def convert_in!(input, message)
      if is_multiple?
        convert_in_multiple!(input, message)
      else
        Ricer::GTrans.new.valid_iso?(input) or failed_input
        input
      end
    end
    
    def convert_in_multiple!(input, message)
      gtrans = Ricer::GTrans.new
      back = [];
      input.split(',').each do |iso|
        gtrans.valid_iso?(iso) or fail("ricer.plug.params.lang_iso.iso_error", code: iso)
        back.push(iso)
      end
      back
    end
    
    def convert_out!(lang_iso, message)
      lang_iso.to_s
    end
    
  end
end
