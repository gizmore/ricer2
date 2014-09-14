module Ricer::Plugins::Admin
  class Die < Ricer::Plugin

    trigger_is :die
    permission_is :owner
    
    requires_retype

    has_usage and has_usage '<..message..>'
    def execute(message=nil)
      bot.running = false
      bot.servers.online.each do |server|
        server.localize!.connection.send_quit(@message, message||default_quit_message)
      end
    end
    
    def default_quit_message
      t :default_message, user: sender.displayname
    end
    
  end
end
