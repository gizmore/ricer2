module Ricer::Plugins::Todo
  class Raise < Ricer::Plugin
    
    trigger_is "todo raise"
    
    has_usage "<id>"
    def execute(id)
      byebug
    end
    
  end
end
