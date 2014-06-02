module Ricer::Plugins::Admin
  class Reboot < Ricer::Plugin
    
    trigger_is :reboot

    permission_is :responsible
    
    requires_retype
    
    has_usage :execute, '[<..message..>]'    
    def execute(message)
      bot.reboot = true
      exec_line "die #{message}"
    end

  end
end
