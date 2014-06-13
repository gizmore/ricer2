module Ricer::Plugins::Gang
  class Npc < Player
    
    before_create do
      self.set_random_name unless self.npc_name.nil?
    end
    
    def self.base_attributes
      {
        npc_class: name.rsubstr_from('::World::'),
      }
    end

    def self.bonus_attributes
      {
      }
    end
    
    def self.spell_attributes
      {
      }
    end
    
    def set_random_name
      self.set_base(:npc_name, get_random_name)
    end
    
  end
end