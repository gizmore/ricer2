module Ricer::Plugins::Gang
  class Commands::Inventory < Command
    
    is_list_trigger :for => Ricer::Plugins::Gang::Item

    def visible_relation(relation)
      return relation.where(:player => player, :slot => :inventory)
    end
        
  end
end
