module Ricer::Plugins::Core
  class In < Ricer::Plugin
    
    trigger_is :in
    permission_is :voice
    
    has_usage :execute_in, '<duration> <trigger>'
    has_usage :execute_in_with_args, '<duration> <trigger> <..command..parameters..>'
    
    def execute_in(delay, plugin)
      execute_in_with_args(delay, plugin, nil)
    end
 
    def execute_in_with_args(delay, plugin, parameters)
      Ricer::Thread.execute do
        line = plugin.trigger
        line += " #{parameters}" if parameters
        bot.log_debug("Sleeping for #{delay} and then execute #{line}")
        sleep(delay)
        plugin.exec_argline(line)
      end
    end
    
  end
end
