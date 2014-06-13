module Ricer::Plugins::Gang
  class Peine::Doener < Quest
    
    npc = spawn_stationary :npc_class => 'RailwayStranger', npc_name: 'Eva', at: 'Peine::Railway' do |klass|
      
      klass.ai_talker do

        chat_about_quest(quest_name)
        
      end
      
    end
    
    bring '2xDoener', to: npc, within: 30.minutes
    
    reward_is 500, 5, 'Apple'
    
  end
end
