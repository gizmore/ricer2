module Ricer::Plugins::Gang
  class Commands::Tell < Command
    
    trigger_is :tell
    
    has_usage :execute, '<target> <string>'
    def execute(target, word)
    end
        
  end
end
