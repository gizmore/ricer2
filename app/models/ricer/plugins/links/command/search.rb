module Ricer::Plugins::Links
  class Search < Ricer::Plugin
    
    is_list_trigger "search", :for => Model::Link
    
  end
end