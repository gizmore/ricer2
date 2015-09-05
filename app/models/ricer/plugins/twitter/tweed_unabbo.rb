module Ricer::Plugins::Twitter
  class TweedUnabbo < Ricer::Plugin
    
    is_remove_abbo_trigger :for => Ricer::Plugins::Twitter::Model::Follow, :trigger => 'twitter unabbo'

    def abbo_find(relation, term)
      relation.where(:name => term).first or relation.find(term)
    end

  end
end
