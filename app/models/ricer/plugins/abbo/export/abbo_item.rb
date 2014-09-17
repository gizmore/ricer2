module Ricer::Plugins::Abbo
  class AbboItem < ActiveRecord::Base
    
    belongs_to :item, :polymorphic => true
    
    def self.upgrade_1
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :item_id,   :null => false
          t.string  :item_type, :null => false, :charset => :ascii, :collation => :ascii_bin
        end
      end
    end
    
    def self.for(abbonementable)
      first_or_creaty_by({item: abbonementable})
    end
    
  end
  
  AbboItem.upgrade_1
  
end

