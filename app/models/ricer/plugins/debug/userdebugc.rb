module Ricer::Plugins::Debug
  class Userdebugc < Ricer::Plugin
    
    trigger_is :udbg
    scope_is :channel
    
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
        channel: channel.displayname,
        chanmode: user.chanperms_for(channel).usermode.display,
        chanpriv: user.chanperms_for(channel).display_permissions,
      }
    end

  end
end
