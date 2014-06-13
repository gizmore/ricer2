module Ricer::Plugins::Gang
  class ItemName < ActiveRecord::Base
    
    self.table_name = :gang_item_names
    
    def to_s; self.name; end
    def to_label; self.name; end

    belongs_to :item, :class_name => 'Ricer::Plugins::Gang::Item'
    belongs_to :locale, :class_name => 'Ricer::Locale'
    
    scope :for_locale, ->(locale) { where({:locale => locale}) }
    
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :item_id,   :null => false
          t.integer :locale_id, :null => false
          t.string  :name
        end
      end
    end
    
  end
end
