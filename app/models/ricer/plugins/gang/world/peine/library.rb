module Ricer::Plugins::Gang
  class World::Peine::Library < Location
    
    def is_searchable(&proc)
      class_eval do |klass|
        ActiveSupport::Notifications.subscribe "gang.on_entered_locationmy.custom.event" do |name, started, finished, unique_id, data|
          puts data.inspect # {:this=>:data}
        end
        
      end
    end
      
    
    is_searchable do |player|
      
      
      
      
      
    end
  
  end
end
