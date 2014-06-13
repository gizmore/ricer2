module Ricer::Plugins::Gang
  class World::Peine::CityPalast < Location
    spawns_stationary npc_class: 'Salesman', npc_name: 'Erkan' do |npc, klass|
      npc.ai_talker do
        chatter(:hello)
      end
    end
  end
end
