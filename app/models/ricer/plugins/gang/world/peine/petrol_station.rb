module Ricer::Plugins::Gang
  class World::Peine::PetrolStation < Location
    
    is_selling_item 'WaterBottle', :for => 1.30
    is_selling_item 'Snickers', :for => 1.80

    is_selling do |player|
      {
        'WaterBottle' => 1.30,
      }
    end
    
    is_buying do |player, item|
      
    end

  end
end