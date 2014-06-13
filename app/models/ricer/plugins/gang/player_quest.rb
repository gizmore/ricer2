module Ricer::Plugins::Gang
  class PlayerQuest < ActiveRecord::Base
    
    self.table_name = :gang_player_quests
    
    belongs_to :quest, :class_name => 'Ricer::Plugins::Gang::Quest'
    belongs_to :player, :class_name => 'Ricer::Plugins::Gang::Player'
    
    has_many :quest_attributes, :class_name => 'Ricer::Plugins::Gang::QuestAttribute'
    has_many :values, :class_name => 'Ricer::Plugins::Gang::AttributeValue', :through => :quest_attributes
    
    delegate :quest_class, :to => :quest
    
    def self.upgrade_0
      return if table_exists?
      enum :state => [:open, :accepted, :denied, :failed, :completed]
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer :quest_id,  :null => false
        t.integer :player_id, :null => false
        t.integer :state,     :null => false, :default => states[:open]
        t.timestamps
      end
    end
    
    def invoke(function, *args)
      klass = quest_class
      klass.send(function, *args) if klass.respond_to?(function) 
    end
    
  end
  
end
