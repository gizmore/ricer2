module Ricer::Plugins::Gang
  class Spell < ActiveRecord::Base
    
    self.table_name = :gang_spells
    
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.string :name
        end
      end
    end
    
    def spell_name
      self.class.short_name.downcase.to_sym
    end
    
    def spell_class
      Object.const_get("Ricer::Plugins::Gang::Spells::#{self.class.short_name}")
    end
    
    def spell_object
      spell_class.new(attributes)
    end
    
    def invoke(function, *args)
      spell_object.send(function, *args) if spell_class.respond_to?(function)
    end
    
    def self.cast(target, level)
      rply :err_stub_spell
    end
    
  end
  
end
