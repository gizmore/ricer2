module Ricer::Plugins::Gang
  class Commands::Look < Command
    
    is_list_trigger :l, :for => 'Ricer::Plugins::Gang::Player'
    
    def visible_relation(players)
      players.near(player)
    end
        
  end
end
