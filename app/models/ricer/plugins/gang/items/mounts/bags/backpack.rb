module Ricer::Plugins::Gang
  class Items::Mounts::Bags::Backpack < Mount
    
    def apply(player)
      player.increase(:max_carry, 1500)
      player.increase(:travel, 2)
    end
    
    
    
  end
end
