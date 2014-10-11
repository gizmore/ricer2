module Ricer::Plugins::Quote
  class VoteDown < Ricer::Plugin
    
    is_vote_down_trigger :for => Ricer::Plugins::Quote::Model::Quote
    
  end
end
