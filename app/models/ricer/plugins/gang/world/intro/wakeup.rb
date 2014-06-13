module Ricer::Plugins::Gang
  class World::Intro::Wakeup < Quest
    
    def gang_on_init
      ActiveSupport::Notifications.subscribe "gang.on_command" do |name, started, finished, unique_id, data|
        puts data.inspect # {:this=>:data}
      end
    end
      
  end
end
