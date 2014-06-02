module Ricer::Plugins::Admin
  class Die < Ricer::Plugin

    trigger_is :die
    permission_is :owner
    
    requires_retype

    has_usage :execute, '[<..message..>]'
    def execute(message)
      message = message||default_message
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
