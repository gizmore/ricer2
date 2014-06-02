module Ricer::Plugins::Rss
  class List < Ricer::Plugin
    
    is_list_trigger :feeds, :for => Ricer::Plugins::Rss::Feed

  end
end
