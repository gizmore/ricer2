module Ricer::Plugins::Cvs
  class List < Ricer::Plugin
    
    is_list_trigger :list, :for => Ricer::Plugins::Cvs::Repo
    
  end
end
