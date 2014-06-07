module Ricer::Plugins::Note
  class List < Ricer::Plugin
    
    is_list_trigger :inbox, :for => Ricer::Plugins::Note::Message
    
    protected
    def visible_relation(relation)
      relation.inbox(user)
    end
    
  end
end
