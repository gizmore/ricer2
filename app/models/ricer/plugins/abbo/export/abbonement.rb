module Ricer::Plugins::Abbo
  class Abbonement < ActiveRecord::Base
    
    belongs_to :abbo_item,   :class_name => 'Ricer::Plugins::Abbo::AbboItem'
    belongs_to :abbo_target, :class_name => 'Ricer::Plugins::Abbo::AbboTarget'
    
    def self.upgrade_1
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :abbo_item_id,     null:false
          t.integer :abbo_target_id,   null:false
          t.timestamps
        end
      end
    end
    
    def self.for_target(target)
      where(:abbo_target => AbboTarget.for(target))
    end
    
    def target
      abbo_target.target
    end

    def item
      abbo_item.object
    end
    
    def display_list_item(n=0)
      item.display_list_item(n)
    end
    def display_show_item(n=0)
      item.display_show_item(n)
    end
    
    search_syntax do
      search_by :text do |scope, phrases|
        scope
      end
    end
    
  end
  
  Abbonement.upgrade_1
  
end
