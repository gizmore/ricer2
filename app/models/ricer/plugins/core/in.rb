module Ricer::Plugins::Core
  class In < Ricer::Plugin
    
    trigger_is :in
    permission_is :voice
    
    has_usage :execute_in, '<duration> <trigger> [<..command..parameters..>]'
    
    def execute_in(delay, plugin, parameters)
      Ricer::Thread.execute do
        sleep(delay)
        line = plugin.trigger
        line += " #{parameters}" unless parameters.nil?
        plugin.exec_line(line)
      end
    end
    
  end
end
