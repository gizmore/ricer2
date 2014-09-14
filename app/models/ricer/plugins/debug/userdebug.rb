module Ricer::Plugins::Debug
  class Userdebug < Ricer::Plugin
    
    trigger_is :udbg
    permission_is :operator
    
    has_usage and has_usage '<user>'
    def execute(user=nil)
      user ||= sender
      args = {
        id: user.id,
        user: user.displayname,
        usermode: user.usermode.display,
        servpriv: user.permission.display,
        hostmask: user.hostmask,
        server: user.server.displayname,
      }
      if channel = self.channel
        chanperm = user.chanperm_for(channel)
        args.merge!({
          channel: channel.displayname,
          chanmode: chanperm.chanmode.display,
          chanpriv: chanperm.permission.display,
        })
        rply(:msg_userinfo_c, args)
      else
        rply(:msg_userinfo_u, args)
      end
    end

  end
end
