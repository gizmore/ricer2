module Ricer::Plugins::Gang
  class SpellAttribute < ActiveRecord::Base
    
    belongs_to :player, :class_name => 'Ricer::Plugins::Gang::Player'
    belongs_to :spell, :class_name => 'Ricer::Plugins::Gang::Spell'
    belongs_to :value, :class_name => 'Ricer::Plugins::Gang::AttributeValue'
    
    delegate :attribute, :to => :value
    delegate :spell_class, :to => :spell
    
    self.table_name = :gang_spell_attributes
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :player_id
          t.integer :spell_id
          t.integer :value_id
        end
      end
    end
  end
  
end
