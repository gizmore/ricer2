module Ricer::Plugins::Twitter
  class TweedAbbo < Ricer::Plugin
    
    is_add_abbo_trigger :for => Ricer::Plugins::Twitter::Model::Follow, :trigger => 'twitter abbo'

    def abbo_find(relation, term)
      relation.where(:name => term).first or relation.find(term)
    end

  end
end
