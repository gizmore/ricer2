module Ricer::Plugins::Gang
  class Race
    
    def race_name
      self.class.race_name
    end
    
    def self.race_name
      name.rsubstr_from('::').underscore.to_sym
    end
    
    def race_class
      Object.const_get("Ricer::Plugins::Gang::Races::#{race_name}")
    end
    
  end
  
end