module Ricer::Plugins::Gang
  module World::Peine
    class Peiner < Ricer::Plugins::Gang::Npc
      
      def self.race(player); either(:human=>100, :nerd=>60, :bully=>60); end
      
      def self.items(player)
        
        [
          either(:knife => 10),
          'Clothes',
          'Shoes',
          either('FirstAid' => 2),
          either('Apple' => 10),
        ]
        
      end
      
      def on_say
        chat_about(:shut_up) if rand < 0.2
      end
      
      def on_tell
        chat_about?(:hello) do
          chat_about(:welcome_to_peine)
        end
      end
      
    end
  end
end
