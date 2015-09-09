module Ricer::Plugins::Links
  class List < Ricer::Plugin
    
    is_list_trigger "links", :for => Model::Link
    
  end
end
