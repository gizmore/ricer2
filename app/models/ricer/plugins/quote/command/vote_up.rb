module Ricer::Plugins::Quote
  class VoteUp < Ricer::Plugin
    
    is_vote_up_trigger :for => Ricer::Plugins::Quote::Model::Quote
    
  end
end
