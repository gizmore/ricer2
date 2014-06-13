module Ricer::Plugins::Gang
  class Commands::Fight < Command
    
    trigger_is :fi
    
    has_usage '<target>'
    def execute(target)
      player.action = :fight
      player.target = target.id
      player.save!
      
      player.weapon.attack(target)
    end

  end
end
