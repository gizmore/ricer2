module Ricer::Plug
  class Password 
    
    def initialize(string)
      @string = string
    end
    
    def empty?
      @string.nil? || @string.empty?
    end
    
    def to_s
      @string.nil? ? '' : @string.to_s
    end
    
    def length
      empty? ? 0 : @string.length
    end
    
    def matches?(password)
      empty? ? false : BCrypt::Password.new(@string).is_password?(password)
    end
    
  end
end
