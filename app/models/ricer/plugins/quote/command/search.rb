module Ricer::Plugins::Quote
  class Search < Ricer::Plugin
    
    is_list_trigger :search,
      :for => Ricer::Plugins::Quote::Model::Quote,
      :pagination_pattern => false,
      :per_page => 5
    
  end
end
