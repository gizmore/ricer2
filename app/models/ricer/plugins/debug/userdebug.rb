module Ricer::Plugins::Debug
  class Userdebug < Ricer::Plugin
    
    trigger_is :udbg
    scope_is :user
    
    has_usage :execute, '[<user>]'
    def execute(user)
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
