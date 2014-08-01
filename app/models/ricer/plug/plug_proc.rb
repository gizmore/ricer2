module Ricer::Plug
  class PlugProc
    
    def initialize(plugin, delay=5.0)
      @plugin = plugin
      @time = 0.0
      @last_line = nil
      @delay = delay
    end

    def finalize
      @plugin.reply @last_line unless @last_line.nil?
    end
    
    def reply(message)
      now = Time.now.to_f
      if (now-@delay) > @time
        @time = now
        @plugin.reply message
        @last_line = nil
      else
        @last_line = message
      end
    end
    
  end
end
