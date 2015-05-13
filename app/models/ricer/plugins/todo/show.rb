module Ricer::Plugins::Todo
  class Show < Ricer::Plugin
    
    is_list_trigger :search,
      :for => Ricer::Plugins::Todo::Model::Entry,
      # :pagination_pattern => false,
      :per_page => 5
    
    def execute(entry)
      show(entry)
    end
    
    def show(entry)
      reply(entry.display_item(entry.id))
    end

    def order_relation(relation)
      relation.order("priority desc")
    end

  end
end
