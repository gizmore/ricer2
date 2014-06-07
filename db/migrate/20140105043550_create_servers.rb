class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.integer :bot_id,      :null => false
      t.string  :connector,   :default => 'irc', :null => false
      t.string  :triggers,    :default => ',',   :null => false, :length => 4
      t.integer :throttle,    :default => 3,     :null => false
      t.float   :cooldown,    :default => 0.8,   :null => false
      t.boolean :enabled,     :default => 1,     :null => false
      t.boolean :online,      :default => false, :null => false
      t.timestamps
    end
    
    create_table :server_urls do |t|
      t.integer :server_id, :null => false
      t.string  :ip,  :length => 43
      t.string  :url, :null => false
      t.boolean :peer_verify, :default => false, :null => false
      t.timestamps
    end
    
  end
end
