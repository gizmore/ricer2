module Ricer::Plugins::Gang
  class World::Nerd < Npc
    
    is_talker do
      is_chat_about?(:wechall) do 
      end
      chatter(:renraku)
    end
    
  end
end
