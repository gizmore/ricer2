module Ricer::Plugins::Debug
  class Userdebug < Ricer::Plugin
    
    trigger_is :udbg
    scope_is :user
    
    has_usage :execute, ''
    has_usage :execute_u, '<user>'
    def execute; execute_u(sender); end
    def execute_u(user)
      user = sender if user.nil?
      rply :msg_userinfo, {
        id: user.id,
        user: user.displayname,
        usermode: user.usermode.display,
        servpriv: user.display_permissions,
        hostmask: user.prefix,
        server: user.server.displayname,
      }
    end

  end
end
