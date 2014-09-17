module Ricer::Plugins::Admin
  class Raw < Ricer::Plugin
    
    trigger_is :raw

    permission_is :responsible
    
    has_usage :execute, '<..message..>'
    def execute(message)
      server.connection.send_raw(current_message, message)
    end
    
  end
end
