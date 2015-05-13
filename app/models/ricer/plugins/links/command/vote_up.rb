module Ricer::Plugins::Links
  class VoteUp < Ricer::Plugin
    
    is_vote_up_trigger :for => Ricer::Plugins::Links::Model::Link
    
  end
end
