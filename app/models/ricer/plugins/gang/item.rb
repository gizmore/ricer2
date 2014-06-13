module Ricer::Plugins::Gang
  class Item < ActiveRecord::Base
    
    def item_name; self.class.item_name; end
    def self.item_name; name.rsubstr_from('::Items::'); end
    def item_class; Object.const_get("Ricer::Plugins::Gang::Items::#{item_name}"); end

    has_many :texts, :class_name => 'Ricer::Plugins::Gang::ItemName'
    
    self.table_name = :gang_items
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.string :name, :null => false, :unique => true
        end
      end
    end
    
    def to_label
      texts.where({locale:I18n.locale}).to_label
    end
    
    
  end
end
