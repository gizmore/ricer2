module Ricer::Plugins::Gang
  class ItemAttribute < ActiveRecord::Base

    belongs_to :item, :class_name => 'Ricer::Plugins::Gang::Item'
    belongs_to :value, :class_name => 'Ricer::Plugins::Gang::AttributeValue'
    
    scope :crafted, -> { where(:crafted => 1) }
    scope :uncrafted, -> { where(:crafted => 0) }
    
    delegate :item_class, :to => :item
    delegate :attribute, :attribute_class, :section, :to => :value
    
    self.table_name = :gang_item_attributes
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :item_id
          t.integer :value_id
          t.boolean :crafted, :default => 0
        end
      end
    end
    
  end

end
