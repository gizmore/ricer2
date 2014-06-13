module Ricer::Plugins::Gang
  class World::World < City
    
    WORLD = Box(-180, 180, -90, 90)
    
    has_bounds WORLD
    
    # spawns_fighting 'Lamer', :box => WORLD
    # spawns_fighting 'Cop', :box => WORLD
    spawns_for_player 'Nerd', :box => WORLD
    # spawns_for_player 'Pinkhead', :box => WORLD
    # spawns_for_player 'Punk', :box => WORLD
    
  end
end
