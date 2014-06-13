module Ricer::Plugins::Gang
  class PlayerKnowledge < ActiveRecord::Base
    
    self.table_name = :gang_player_knowledges

    belongs_to :player, :class_name => 'Ricer::Plugins::Gang::Player'
    belongs_to :knowledge, :class_name => 'Ricer::Plugins::Gang::Knowledge'
    
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :player_id,    :null => false
          t.integer :knowledge_id, :null => false
        end
      end
    end
    
  end
end
