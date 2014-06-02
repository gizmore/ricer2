module Pile
  class Record < ActiveRecord::Base
    
    self.table_name = :pile_records
    
    def self.upgrade_1
      unless table_exists?
        ActiveRecord::Migration.new do |m|
          m.create_table Pile::Record.table_name do |t|
            t.string  :url,  :null => false
            t.string  :lang, :default => 'text', :length => 32
            t.string  :title
            t.text    :content 
            t.integer :user_id 
            t.timestamps
          end 
        end
      end
    end
    
  end
  Record.upgrade_1
end

