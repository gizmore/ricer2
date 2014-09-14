module Ricer::Plugins::Admin
  class Reboot < Ricer::Plugin
    
    trigger_is :reboot
    permission_is :responsible
    
    requires_retype
    
    has_usage and has_usage '<..message..>'
    def execute(message=nil)
      get_plugin('Admin/Die').execute(message||default_reboot_message)
      pid = spawn "bundle exec rake ricer:start"
      Process.detach(pid)
    end
    
    def default_reboot_message
      t(:default_msg, user: sender.displayname)
    end

  end
end
