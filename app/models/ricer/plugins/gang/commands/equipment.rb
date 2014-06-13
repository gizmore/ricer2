module Ricer::Plugins::Gang
  class Commands::Equipment < Command
    
    is_list_trigger :for => Ricer::Plugins::Gang::Item

    def visible_relation(relation)
      return relation.where(:player => player, :slot => :equipment)
    end
        
  end
end
