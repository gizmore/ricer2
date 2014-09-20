module Ricer::Plug::Params
  class BaseOnline < Base
    
    def default_options; { :online => nil, :offline => nil }; end
    
    def online_option
      case options[:online]
      when '1'; true
      when '0'; false
      when nil; nil
      else; raise Ricer::ParamException.new("Plugin param definition is broken -.-")
      end
    end
    
  end
end
