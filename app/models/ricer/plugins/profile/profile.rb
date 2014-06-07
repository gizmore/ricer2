module Ricer::Plugins::Profile
  class Profile < Ricer::Plugin
    
    def upgrade_1
      ProfileEntry.upgrade_1
    end
    
    def execute
      
    end
    
  end
end