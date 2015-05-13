module Mime
  class Type < ActiveRecord::Base
    
    self.table_name = :mime_types
    
    def self.upgrade_1
      unless table_exists?
        m = ActiveRecord::Migration.new
        m.create_table Mime::Type.table_name do |t|
          t.string  :type,  :null => false, :length => 128, :encoding => :ascii
        end
        
      end
    end
    
  end
end

Mime::Type.upgrade_1
