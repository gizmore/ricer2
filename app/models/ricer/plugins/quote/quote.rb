module Ricer::Plugins::Quote
  class Quote < Ricer::Plugin
    
    has_subcommand :add
    has_subcommand :search
    has_subcommand :stats
    has_subcommand :votedown
    has_subcommand :voteup
   
    def upgrade_1
      Ricer::Plugins::Quote::Model::Quote.upgrade_1
    end
    
  end
end