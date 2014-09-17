module Ricer::Plugins::Abbo
  class AbboTarget < ActiveRecord::Base
    
    belongs_to :target, :polymorphic => true
    
    def self.upgrade_1
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :target_id,   :null => false
          t.string  :target_type, :null => false, :charset => :ascii, :collation => :ascii_bin
        end
      end
    end
    
    def self.for(target)
      find_or_create_by({target: target})
    end
    
  end
  
  AbboTarget.upgrade_1
  
end