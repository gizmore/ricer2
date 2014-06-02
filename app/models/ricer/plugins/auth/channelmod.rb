module Ricer::Plugins::Auth
  class Channelmod < Ricer::Plugin
  
    trigger_is :modc

    has_usage :execute_cshow, '[<user>]', scope: :channel 
    has_usage :execute_cchange, '<user> [<permission>]', scope: :channel

    has_usage :execute_show_u, '<channel> [<user>]', scope: :user
    has_usage :execute_change_u, '<channel> <user> <permission>', scope: :user
        
    def execute_cshow(user=nil)
      execute_show_u(channel, user)
    end

    def execute_cchange(user, permission)
      execute_change_u(channel, user, permission)
    end
  
    def execute_show_u(channel, user)
      user = sender if user.nil?
      p = user.chanperm_for(channel)
      rply :msg_show_chan,
        user: user.displayname,
        bitstring: p.merged_permission.display,
        channel: channel.displayname,
        server: server.displayname
    end

    def execute_change_u(channel, user, permission)
    end

  end
end
