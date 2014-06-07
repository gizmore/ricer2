module Ricer::Plug
  class UsageParam
    
    def to_label; @parser.param_label; end

    def is_eater?; @eater; end
    def is_optional?; @optional; end
    def is_mandatory?; !@optional; end
    
    def initialize(paramstring)
      
      @eater = paramstring.index('.') != nil
      @optional = paramstring.index('[') != nil
      #@type = paramstring.trim('[<.>]')
      unless @eater
        @parser = Param.parser!(paramstring.trim('[<.>]'))
      else
        @parser = Param.parser!('message')
      end
    end
    
    def parse(input, options, message)
      @parser.convert_in!(input, options, message)
    end
    
    # def print(value, options, message)
      # @parser.convert_out!(value, options, message)
    # end
    
  end
end
