module Ricer::Plugins::Gang
  class Gender::Female < Gender
    
    def self.bonus_attributes(player)
      {
        charisma: 2,
        intelligence: 1,
        quickness: -1,
        strength: -2,
      }
    end
  end
end
