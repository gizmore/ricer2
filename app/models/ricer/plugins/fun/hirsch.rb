module Ricer::Plugins::Fun
  class Hirsch < Ricer::Plugin
    
    trigger_is :hirsch
    
    has_usage
    def execute
      rply :msg_hirsch
    end
    
  end
end
