module Ricer::Plugins::Gang
  module Locations::Store
    
    def is_selling(items={}, options={})
      class_eval do |klass|
        
      end
    end
    
    def is_buying(options={}, &proc)
      class_eval do |klass|
        
      end
    end
    
  end
  Location.extend Locations::Store
  
end
