module Ricer::Plugins::Gang
  class Commands::Attack < Command
    
    trigger_is '#'.to_sym
    
    has_usage '<target>'
    def execute(target)
      player.weapon.attack(target)
    end

  end
end
