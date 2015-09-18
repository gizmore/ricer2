module Ricer::Plugins::Quote
  class Search < Ricer::Plugin
    
    is_search_trigger :search,
      :for => Ricer::Plugins::Quote::Model::Quote,
      :per_page => 5
    
  end
end
