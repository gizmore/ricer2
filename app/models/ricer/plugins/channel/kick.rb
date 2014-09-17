module Ricer::Plugins::Channel
  class Kick < Ricer::Plugin
    
    trigger_is :kick
    scope_is :channel
    permission_is :halfop
    
    has_setting name: :kickjoin, type: :boolean, scope: :channel, permission: :operator, default: false
    
    has_usage :execute, '<user>'
    def execute(user)
      reply "Trying to kick #{user.name}"
      server.send_kick(user)
    end
    
    def on_kick
      if get_setting(:kickjoin)
        server.connection.send_join(current_message, channel.name)
      end
    end
        
  end
end