module Ricer::Plugins::Server
  class Nick < Ricer::Plugin
    
    trigger_is :nick
    scope_is :everywhere
    permission_is :ircop
    
    has_usage :execute, '<nickname>'
    def execute(nickname)
      
    end
    
  end
end