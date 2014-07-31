module Ricer::Plugins::Admin
  class Reboot < Ricer::Plugin
    
    trigger_is :reboot

    permission_is :responsible
    
    requires_retype
    
    has_usage :execute_reboot
    def execute_reboot
      execute_with_message(t(:default_msg, user:sender.displayname))
    end
        
    has_usage :execute_with_message, '<..message..>'
    def execute_with_message(message)
      exec_line "die #{message}"
      pid = spawn "bundle exec rake ricer:start"
      Process.detach(pid)
    end

  end
end
