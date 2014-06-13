module Ricer::Plugins::Gang
  class Location < ActiveRecord::Base
    
    self.table_name = :gang_locations

    def self.upgrade_0
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table table_name do |t|
          t.string :name, :length => 64
        end
      end
    end
    
  end
end
