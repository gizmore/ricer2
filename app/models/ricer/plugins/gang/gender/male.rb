module Ricer::Plugins::Gang
  class Gender::Male < Gender
    
    def self.bonus_attributes(player)
      {
        strength: 2,
        quickness: 1,
        intelligence: -1,
        charisma: -2,
      }
    end
    
  end
end