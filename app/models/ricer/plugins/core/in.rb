module Ricer::Plugins::Core
  class In < Ricer::Plugin
    
    trigger_is :in
    
    has_usage '<duration> <trigger>'
    has_usage '<duration> <trigger> <..parameters..>'
    
    def execute(delay, plugin, parameters=nil)
      Ricer::Thread.execute do
        sleep(delay)
        line = plugin.trigger
        line += " #{parameters}" if parameters
        plugin.exec_argline(line)
      end
    end
    
  end
end
