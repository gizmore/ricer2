module Ricer::Plugins::Core
  class Repeat < Ricer::Plugin
    
    trigger_is :repeat
    permission_is :owner
    
    bruteforce_protected
    
    has_usage '<integer[min=1,max=25]> <plugin>'
    has_usage '<integer[min=1,max=25]> <plugin> <..parameters..>'

    def execute(repetitions, plugin, parameters=nil)
      Ricer::Thread.execute{
        line = plugin.trigger
        line += " #{parameters}" if parameters
        current_message.args[1] = line
        repetitions.times {
          plugin.exec_plugin
        }
      }
    end
  end
end
