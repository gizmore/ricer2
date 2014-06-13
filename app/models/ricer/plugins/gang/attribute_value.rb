module Ricer::Plugins::Gang
  class AttributeValue < ActiveRecord::Base
    
    belongs_to :attrib, :class_name => 'Ricer::Plugins::Gang::Attribute'
    
    delegate :attribute_class, :is_runtime_value?, :section, :to => :attrib
    
    self.table_name = :gang_attribute_values
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :attrib_id, :null => false
          t.decimal :base,      :null => true, :precision => 6, :scale => 1
          t.decimal :value,     :null => true, :precision => 6, :scale => 1
          t.string  :setting,   :null => true
        end
      end
    end
    
    def is_base?
      (self.base != nil) && (self.setting != nil)
    end
    
    def is_string?
      (self.setting != nil)
    end
    
    def is_bonus?
      (self.value != nil)
    end
    
    def apply!(player)
      attribute_class.apply(player)
    end
    
    def apply(player)
      player.add_value(self.value)
    end
    
    def self.invoke(function, *args)
      klass = attribute_class
      klass.send(function, *args) if klass.respond_to?(function)
    end
    
  end
end
