module Ricer::Plugins::Twitter
  class TweedUnabbo < Ricer::Plugin
    
    is_remove_abbo_trigger :for => Ricer::Plugins::Twitter::Model::Follow, :trigger => 'twitter unabbo'

  end
end
