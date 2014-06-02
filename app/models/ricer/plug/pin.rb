module Ricer::Plug
  class Pin
    
    def initialize(string)
      @string = string
    end
    
    def to_s
      @string.to_s
    end
    
    def matches?(pin)
      pin.gsub(/[^a-z0-9]/i, '').downcase == @string.gsub(/[^a-z0-9]/i, '').downcase
    end
    
  end
end
