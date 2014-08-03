module Ricer::Plugins::Quote
  class Stats < Ricer::Plugin
    
    trigger_is :stats
    
    has_usage :execute
    def execute
      
      rply :msg_stats,
        count: 4,
        votes: 24,
        last_id: 8,
        last_by: 'gizm',
        last_date: '54'
      
    end
    
  end
end
