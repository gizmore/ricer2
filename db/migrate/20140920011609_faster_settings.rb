class FasterSettings < ActiveRecord::Migration
  def change
    
    drop_table :settings
    
    create_table :settings do |t|
      t.integer :plugin_id,   :null => false
      t.string  :name,        :null => false, :limit => 32,  :charset => :ascii, :collation => :ascii_bin
      t.integer :entity_id,   :null => false
      t.string  :entity_type, :null => false, :limit => 128, :charset => :ascii, :collation => :ascii_bin
      t.string  :value,       :null => false
      t.timestamps
    end
    
    add_foreign_key :settings, :plugins, :name => :settings_for_plugins, :column => :plugin_id

    add_index :settings, [:plugin_id, :name, :entity_id, :entity_type], :name => :unique_settings, :unique => true
    
  end
end
