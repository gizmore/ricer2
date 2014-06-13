module Ricer::Plugins::Gang
  class Loot < ActiveRecord::Base
    
    belongs_to :item, :class_name => 'Ricer::Plugins::Gang::Item'
    has_many   :attribs, :class_name => 'Ricer::Plugins::Gang::ItemAttribute'
    has_many   :values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_item_attributes
    
    self.table_name = :gang_loot_items
    def self.upgrade_0
      return if table_exists?
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer  :item_id,   :null => false
        t.float    :latitude,  :null => false
        t.float    :longitude, :null => false
      end
    end
    
    def item_class
      Object.const_get("Ricer::Plugins::Gang::#{item.item_name}")
    end
    
    def item_object
      item_class.new
    end
    
  end

end
