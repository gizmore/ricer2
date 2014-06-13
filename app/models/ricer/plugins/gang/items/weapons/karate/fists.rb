module Ricer::Plugins::Gang::Items
  class Weapons::Karate::Fists < KarateWeapon
    
    def self.attributes(player)
      {
        attack: 2,
        min_damage: 1,
        max_damage: 3,
      }
    end
    
  end
end
