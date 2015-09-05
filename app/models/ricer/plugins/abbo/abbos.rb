module Ricer::Plugins::Abbo
  class Abbos < Ricer::Plugin
    
    is_abbo_list_trigger :trigger => :abbos, :for => Ricer::Plugins::Abbo::Abbonement

    # def visible_relation(relation)
      # return relation.visible(user) if relation.respond_to?(:visible)
      # relation
    # end
    
  end
end
