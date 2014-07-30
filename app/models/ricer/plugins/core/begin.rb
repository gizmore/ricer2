module Ricer::Plugins::Core
  class Begin < Ricer::Plugin
    
    trigger_is :begin
    permission_is :voice
    has_priority 3

    has_usage :execute_begin, '<trigger> [<..command..args..>]'

    def on_privmsg
      if has_line? # something to operate on?
        if @message.is_trigger_char? # Explicit triggered with!.,?
          remove_line # we remove, and just execute this
        else
          append_line # Catch in our queue
        end
      end
    end
    
    def has_line?
      user.instance_variable_defined?(:@multiline_command)
    end
    
    def get_line
      user.instance_variable_get(:@multiline_command)
    end
    
    def set_line(line)
      user.instance_variable_set(:@multiline_command, line)
      @message.processed = true
    end
    
    def remove_line
      @message.processed = true
      user.remove_instance_variable(:@multiline_command) if has_line?
    end
    
    def append_line
      set_line(get_line + privmsg_line + "\n")
    end
    
    def execute_begin(plugin, arguments)
      line = plugin.trigger + ' '
      line += (arguments + ' ') unless arguments.nil?
      set_line(line)
    end
    
    def finish
      return rply :err_no_begin unless has_line?
      exec_line(remove_line)
    end

  end
end
