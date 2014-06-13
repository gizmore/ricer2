module Ricer::Plugins::Gang
  class Attributes::Hp < AttributeValue
    
    before_save :clamp
    after_save  :check_death
    
    def clamp
      [self.value.to_f, 0].max
    end
    
    
  end
end
