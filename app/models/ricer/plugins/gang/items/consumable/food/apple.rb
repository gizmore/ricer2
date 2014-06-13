module Ricer::Plugins::Gang
  module Items
    class Food::Apple < Edible
      
      def self.attributes(player)
        {
          weight: 80
          
        }
      end
      
    end
  end
end