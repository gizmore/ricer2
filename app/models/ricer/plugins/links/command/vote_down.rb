module Ricer::Plugins::Links
  class VoteDown < Ricer::Plugin
    
    is_vote_down_trigger :for => Ricer::Plugins::Links::Model::Link
    
  end
end
