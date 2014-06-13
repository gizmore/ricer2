module Ricer::Plugins::Gang
  class QuestAttribute < ActiveRecord::Base
    
    self.table_name = :gang_quest_attributes
    
    belongs_to :quest, :class_name => 'Ricer::Plugins::Gang::Quest'
    belongs_to :player, :class_name => 'Ricer::Plugins::Gang::Player'
    belongs_to :value, :class_name => 'Ricer::Plugins::Gang::AttributeValue'
    
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :quest_id,  :null => false
          t.integer :player_id, :null => false
          t.integer :value_id,  :null => false
        end
      end
    end
  end
  
end
