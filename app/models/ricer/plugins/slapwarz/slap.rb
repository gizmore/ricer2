module Ricer::Plugins::Slapwarz
  class Slap < Ricer::Plugin
    
    trigger_is :slap
    
    has_setting name: :penalty, type: :integer,  scope: :channel, permission: :admin,       min: 0, max: 10000,   default: 10
    has_setting name: :penalty, type: :integer,  scope: :server,  permission: :responsible, min: 0, max: 10000,   default: 10
    has_setting name: :timeout, type: :duration, scope: :channel, permission: :admin,       min: 0, max: 1.month, default: 1.day
    has_setting name: :timeout, type: :duration, scope: :server,  permission: :responsible, min: 0, max: 1.month, default: 1.day
        
    has_usage :execute, '<user[online=1]>', scope: :server
    def execute(target)
      # if remainslap?(user, target, channel)
        # insert_remainslap(user, channel)
        # return rply(:msg_remainslap,
          # penalty: 1
        # )
      # end
      
    end

    has_usage :execute_channel, '<channel_user>', scope: :channel
    def execute_channel(target)
      
    end
    
  end
end