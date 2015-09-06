module Ricer::Plugins::Cvs
  class Abbo < Ricer::Plugin
    
    is_add_abbo_trigger :for => Ricer::Plugins::Cvs::Repo

    def abbo_find(relation, term)
      relation.where(:name => term).first or relation.find(term)
    end

  end
end
