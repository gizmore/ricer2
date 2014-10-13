class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.integer :bot_id,      :default => nil,   :null => false, :limit => 2
      t.string  :connector,   :default => 'irc', :null => false, :limit => 16, :charset => :ascii, :collation => :ascii_bin
      t.string  :triggers,    :default => ',',   :null => false, :limit => 4
      t.integer :throttle,    :default => 4,     :null => false, :limit => 5, :unsigned => true
      t.float   :cooldown,    :default => 0.5,   :null => false
      t.boolean :enabled,     :default => true,  :null => false
      t.boolean :online,      :default => false, :null => false
      t.timestamps
    end
    
    create_table :server_urls do |t|
      t.integer :server_id, :null => false
      t.string  :ip,  :null => true,  :limit => 43,   :charset => :ascii, :collation => :ascii_bin
      t.string  :url, :null => false, :unique => true
      t.boolean :peer_verify, :null => false, :default => false
      t.timestamps
    end
    
  end
end
