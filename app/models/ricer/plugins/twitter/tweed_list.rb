module Ricer::Plugins::Twitter
  class TweedList < Ricer::Plugin
    
    is_list_trigger "twitter feeds", :for => Ricer::Plugins::Twitter::Model::Follow

  end
end
