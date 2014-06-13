module Ricer::Plugins::Gang::Items
  class Weapons::Blunts::Stool < Blunt
    
    def self.attributes(player)
      [
        weight: avg(600, 1200),
        attack: avg(2, 4),
        min_damage: avg(1, 2),
        max_damage: avg(3, 5),
        defense: avg(0.5, 1.5),
        marm: avg(0.5, 1.5),
        farm: avg(0.5, 1.5),
      ]
    end
    
  end
end
