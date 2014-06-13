module Ricer::Plugins::Gang
  class Quest < ActiveRecord::Base
    
    self.table_name = :gang_quests
    
    # has_many :solvers, -> { where(state: states[:solved]) }, :class_name => 'Ricer::Plugins::Gang::Player', :through => :gang_player_quests
    has_many :players, :class_name => 'Ricer::Plugins::Gang::Player', :through => :gang_player_quests
    scope :players_with, ->(state) { players.where(:state => state) }
    has_many :solvers, -> { players_with(:solved) }
    
    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.string :name, :null => false
        end
      end
    end
    
    def self.by_name(name)
      self.first_or_create({name: name})
    end
    
    def title
      t(:title)
    end
    
    def description
      t(:description)
    end
    
  end
  
end
