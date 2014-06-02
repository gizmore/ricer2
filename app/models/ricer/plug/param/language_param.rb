module Ricer::Plug::Param
  class LanguageParam < Base

    def self.get_arg(server, arg, message)
      
      Ricer::Locale.by_iso(arg)

    end
    
  end
end
