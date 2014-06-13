module Ricer::Plugins::Gang
  class World::Peine::Startup < Quest
    
    def on_build_commands
      player.commands.delete_all
      
      
      
    end
    
    def reward
    end
    
    
  end
end