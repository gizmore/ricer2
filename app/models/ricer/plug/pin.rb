module Ricer::Plug
  class Pin
    
    def initialize(string)
      @string = string
    end
    
    def to_s
      @string.to_s
    end
    
    def to_label
      @string.to_s
    end
    
    def to_value
      @string.gsub(/[^a-z0-9]/i, '')
    end
    
    def matches?(pin)
      pin.gsub(/[^a-z0-9]/i, '') == self.to_value
    end
    
    def self.random_block
      SecureRandom.base64(3).gsub('/', 'a')
    end
    
    def self.random_label
      self.random_block + '-' + self.random_block
    end
    
    def self.random_pin
      new(random_label)
    end
    
  end
end
