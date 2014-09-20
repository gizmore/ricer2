module Ricer::Plug::Params
  class FilenameParam < StringParam
    
    def valid_filename?(input)
      !!/^[a-z0-9_.-]$/i.match(input)
    end
    
    def convert_in!(input, message)
      fail(:err_filename) unless valid_filename?(input)
      input
    end
    
    def convert_out!(value, message)
      value
    end
    
  end
end
