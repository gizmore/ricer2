module Ricer::Plugins::Admin
  class Die < Ricer::Plugin

    trigger_is :die
    permission_is :owner
    
    requires_retype

    has_usage :execute
    def execute
      execute_with_message(default_message)
    end

    has_usage :execute_with_message, '<..message..>'
    def execute_with_message(message)
      bot.servers.each do |server|
        server.connection.send_quit(@message, message) if server.connected?
      end
      bot.running = false
    end
    
    private
    
    def default_message
      t(:default_message, :user => sender.displayname)
    end
    
  end
end
