module Ricer::Plugins::Abbo
  class AbboItem < ActiveRecord::Base
    
    belongs_to :object, :polymorphic => true
    
    def self.upgrade_1
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :object_id,   :null => false
          t.string  :object_type, :null => false
        end
      end
    end
    
    def self.for(abbonementable)
      where({object:abbonementable}).first || create({object:abbonementable})
    end
    
  end
  
  AbboItem.upgrade_1
  
end

