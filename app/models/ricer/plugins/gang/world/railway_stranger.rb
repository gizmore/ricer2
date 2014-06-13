module Ricer::Plugins::Gang
  class Npc::RailwayStranger < Npc
    
    ai_talker do(klass)

      chat_is_about?(:hello) do
        chat_is_about?(:wechall) do
          chatter(:not_heard_from_wechall)
        end
        chatter(:hello_stranger)
      end
      
      chat_is_about?(:hello) do
        chat_is_about?(:hacking) do
          chatter(:no_hacking_please)      
        end
      end
      
      chat_is_about_quest('Peine::Doener')

      chatter(:hello_stranger)
      
    end   
  end
end
