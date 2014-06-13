module Ricer::Plugins::Gang
  class Commands::Map < Command
    
    trigger_is :move
    
    has_usage '[<gang_player>]'
    def execute(player)
      player = self.player if player.nil?
      if player == self.player
        rply :msg_your_map, :link => 'https://maps.google.de/test'
      else
        rply :msg_map_for, :link => 'https://maps.google.de/test', :user => player.displayname
      end
    end
        
  end
end
