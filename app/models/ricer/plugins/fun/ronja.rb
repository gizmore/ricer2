module Ricer::Plugins::Fun
  class Ronja < Ricer::Plugin
    
    trigger_is :ronja
    
    has_usage
    def execute
      rply :msg_ronja
    end
    
  end
end
