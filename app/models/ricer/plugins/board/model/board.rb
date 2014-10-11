module Ricer::Plugins::Board
  class Model::Board < ActiveRecord::Base

    self.table_name = :wechall_boards
    
    validates :name, named_id: true
    validates :url,  uri: { ping:false, trust:false, connect:true, exist:true, schemes:[:http,:https] }

    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.string    :name,         :null => false, :length => NamedId.maxlen,   :unique => true, :charset => :ascii, :collation => :ascii_bin
        t.string    :url,          :null => false, :unique => true
        t.timestamps
      end
      
    end
    
    # before_validation :remove_whitespaces
    # def before_save
#       
    # end
    
  end
end
