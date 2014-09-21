module Ricer::Plugins::Auth
  class Channelmod < Ricer::Plugin
  
    trigger_is :modc

    has_usage :execute_cshow, '', scope: :channel 
    has_usage :execute_cshowu, '<user>', scope: :channel 
    has_usage :execute_cchange, '<user> <permission>', scope: :channel

    has_usage :execute_show, '<channel>', scope: :user 
    has_usage :execute_show_u, '<channel> <user>', scope: :user
    has_usage :execute_change_u, '<channel> <user> <permission>', scope: :user
    
    ###################################
    ### Channel funcs call wrappers ###
    ###################################
    def execute_cshow; execute_show_u(channel, user); end
    def execute_cshowu(user); execute_show_u(channel, user); end
    def execute_cchange(user, permission); execute_change_u(channel, user, permission); end

    ##############################
    ### Private query triggers ###
    ##############################
    def execute_show(channel)
       execute_show_u(channel, user)
    end

    def execute_show_u(channel, user)
      p = user.chanperm_for(channel)
      rply(:msg_show_chan,
        user: user.displayname,
        server: server.displayname,
        channel: channel.displayname,
        chanmode: p.chanmode.display,
        bitstring: p.permission.display,
      )
    end

    def execute_change_u(channel, user, permission)
      rplyr :err_stub
      # TODO: Implement :P
    end

  end
end
