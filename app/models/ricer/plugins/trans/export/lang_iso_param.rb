module Ricer::Plug::Params
  class LangIsoParam < Base
    
    def convert_in!(input, message)
      
    end
    
    def convert_out!(lang_iso, message)
      lang_iso.to_s
    end
    
  end
end
