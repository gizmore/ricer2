module Ricer::Plugins::Twitter
  class TweedAbbos < Ricer::Plugin
    
    is_abbo_list_trigger :for => Ricer::Plugins::Twitter::Model::Follow, :trigger => 'twitter abbos'

  end
end
