module Ricer::Plugins::Quote
  class Stats < Ricer::Plugin
    
    trigger_is :stats
    
    has_usage
    def execute
      quotes = Ricer::Plugins::Quote::Model::Quote
      args = {
        count: quotes.count,
        votes: 1,
      }
      if last = quotes.last
        args.merge!({
          last_id: last.id,
          last_by: last.user.displayname,
          last_date: last.displaydate,
        })
      end
      rply :msg_stats, args
    end
    
  end
end
