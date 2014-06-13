module Ricer::Plugins::Gang
  class City
    
    def square_km
      @box.square_km
    end
    
    def box_matches?(box)
      
    end
    
  end
end

module Ricer::Plugins::Gang::CityExtenders
  
  def has_box(box)
    class_eval do |klass|
      @box = box
      @has_bounds = false
    end
    
  end
  
  def has_bounds(box)
    class_eval do |klass|
      
      has_box box
      @has_bounds = true
      
    end
  end
  
  def has_position()
    
    
  end
  
  def has_square_meters
    
  end
  
end

Ricer::Plugins::Gang::City.extend Ricer::Plugins::Gang::CityExtenders
