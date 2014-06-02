module Ricer::Plugins::Ai
  class Raw < Ricer::Plugin
    
    trigger_is :raw
    permission_is :owner
    
    has_usage :execute, '<..message..>'
    def execute(text)
      server.connection.send_raw(@message, text)
    end
    
  end
end
