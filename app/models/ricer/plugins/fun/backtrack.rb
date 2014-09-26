module Ricer::Plugins::Fun
  class Backtrack < Ricer::Plugin
    
    trigger_is :backtrack
    
    has_usage
    def execute
      rply :msg_backtrack
    end
    
  end
end
