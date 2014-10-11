module Ricer::Plugins::Quote
  class Quote < Ricer::Plugin
    
    def upgrade_1
      Ricer::Plugins::Quote::Model::Quote.upgrade_1
    end
    
  end
end
