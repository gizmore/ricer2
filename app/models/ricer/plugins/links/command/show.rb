module Ricer::Plugins::Links
  class Show < Ricer::Plugin
    
    is_list_trigger "show", :for => Model::Link, :search_pattern => '<id>'
    
  end
end
