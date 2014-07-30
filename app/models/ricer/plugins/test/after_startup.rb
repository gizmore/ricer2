module Ricer::Plugins::Test
  class AfterStartup < Ricer::Plugin
  
    def ricer_on_user_loaded
    
      # exec('gang start human male') if Ricer::Irc::User.current.nickname == 'gizmore'
      
    end

  end
end
