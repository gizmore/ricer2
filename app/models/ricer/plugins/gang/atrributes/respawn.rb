module Ricer::Plugins::Gang
  class Attributes::Respawn < AttributeValue
      
    def gang_on_killed(player, victim)
      
    end
    
    def gang_on_died(player)
      respawn(player) if self.value > 0
    end
    
    def respawn(player)
      
    end
      
  end
end
