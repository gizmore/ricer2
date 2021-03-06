module Ricer::Plugins::Debug
  class Dbtrace < Ricer::Plugin
    
    trigger_is :dbtrace
    permission_is :responsible
    
    def plugin_init
      ActiveRecord::Base.logger = nil
    end
    
    has_usage '<boolean>'
    def execute(bool)
      if bool
        ActiveRecord::Base.logger = Logger.new(STDOUT)
        rply :msg_on
      else
        ActiveRecord::Base.logger = nil
        rply :msg_off
      end
    end

  end
end
