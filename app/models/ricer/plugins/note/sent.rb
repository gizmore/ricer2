module Ricer::Plugins::Note
  class Sent < Ricer::Plugin
    
    is_list_trigger :outbox, :for => Ricer::Plugins::Note::Message

    protected
    def visible_relation(relation)
      relation.outbox(user)
    end
    
  end
end
