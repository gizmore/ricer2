module Ricer::Plugins::Abbo
  class AbboTarget < ActiveRecord::Base
    
    belongs_to :target, :polymorphic => true
    
    def self.upgrade_1
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :target_id,   :null => false
          t.string  :target_type, :null => false
        end
      end
    end
    
    def self.for(target)
      where({target:target}).first || create({target:target})
    end
    
  end
  
  AbboTarget.upgrade_1
  
end