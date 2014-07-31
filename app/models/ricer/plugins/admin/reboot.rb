module Ricer::Plugins::Admin
  class Reboot < Ricer::Plugin
    
    trigger_is :reboot

    permission_is :responsible
    
    has_usage :execute_reboot
    def execute_reboot
      execute_with_message(t(:default_msg, sender.displayname))
    end
        
    has_usage :execute_with_message, '<..message..>'
    def execute_with_message(message)
      bot.reboot = true
      exec_line "die #{message}"
    end

  end
end
