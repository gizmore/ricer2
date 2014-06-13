module Ricer::Plugins::Gang
  class PlayerItem < ActiveRecord::Base
    
    belongs_to :item, :class_name => 'Ricer::Plugins::Gang::Item'
    belongs_to :player, :class_name => 'Ricer::Plugins::Gang::Player'
    has_many   :attribs, :class_name => 'Ricer::Plugins::Gang::ItemAttribute'
    has_many   :values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :gang_item_attributes
    
    scope :equipped, -> { where(:equipped => true) }
    
    self.table_name = :gang_player_items
    def self.upgrade_0
      return if table_exists?
      enum slot: [:bank, :bazaar, :clanbank, :equipment, :inventory, :mount]
      # heaven+MP earth= love+HP hate+ST energy+QU matter=
      #enum color: [:blue, :green, :pink, :red, :yellow, white]
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer  :item_id,   :null => false
        t.integer  :player_id, :null => true
        t.integer  :slot,      :null => false, :default => slots[:inventory]
        t.boolean  :equipped,  :null => false, :default => false
      end
    end
    
    # def item_class
      # Object.const_get("Ricer::Plugins::Gang::#{item.item_name}")
    # end
    
    # def item_object
      # item_class.new
    # end
    
  end
end
