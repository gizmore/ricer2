module Ricer::Plugins::Gang
  class Items::Weapons::Blunts::Club < Items::Blunt
    
    def self.attributes(player)
      {
        level: 1,
        worth: avg(3, 6),
        weight: avg(500, 750),
        attack: avg(3, 6),
        min_damage: avg(1, 2),
        max_damage: avg(4, 5),
        defense: avg(0, 1),
        marm: avg(0, 1),
        farm: avg(0, 0),
      }
    end
    
  end
end
