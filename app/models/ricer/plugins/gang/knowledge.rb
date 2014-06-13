module Ricer::Plugins::Gang
  class Knowledge < ActiveRecord::Base
    
    self.table_name = :gang_knowledges
    
    def self.upgrade_0
      unless table_exists?
        enum type: [:knowledge, :place, :word]
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.integer :type, :null => false
          t.string :name, :null => false, :length => 64
        end
      end
    end
    
  end
end
