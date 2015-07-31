module Ricer::Plugins::Admin
  class Upgrade < Ricer::Plugin
    
    trigger_is :upgrade
    permission_is :responsible

    requires_retype
    
    has_usage :execute_upgrade
    def execute_upgrade
      rply :msg_pulling
      Ricer::Thread.execute do
        reply `git reset --hard origin/master && git pull`
      end
    end

  end
end
