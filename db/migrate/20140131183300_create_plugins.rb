class CreatePlugins < ActiveRecord::Migration
  def up
    create_table :plugins do |t|
      t.integer  :bot_id,   :null => false
      t.string   :name,     :null => false
      t.integer  :revision, :null => false, :default => 0, :unsigned => true
      t.timestamps
    end
    create_table :settings, :id => false do |t|
      t.string  :id, :null => false, :length => 64
#      t.integer :plugin_id
#      t.integer :scope
#      t.integer :scope_id
#      t.string  :name
      t.string  :value
    end
    execute "ALTER TABLE settings ADD PRIMARY KEY (id);"
  end
  
  def down
    drop_table :plugins
    drop_table :settings
  end
  
end
