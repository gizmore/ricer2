module Ricer::Plug::Params
  class BaseOnline < Base
    
    def default_options; { :online => nil, :offline => nil }; end
    
    def online_option
      return true unless options[:online].nil?
      return false unless options[:offine].nil?
      return nil
    end
    
  end
end
