class CreatePlugins < ActiveRecord::Migration
  def up
    create_table :plugins do |t|
      t.integer  :bot_id,   :null => false
      t.string   :name,     :null => false, :limit => 96, :charset => :ascii, :collation => :ascii_bin
      t.integer  :revision, :null => false, :limit =>  3, :default => 0, :unsigned => true
      t.timestamps
    end
    create_table :settings do |t|
      # t.string  :id, :null => false, :length => 32, :charset => :ascii, :collation => :ascii_bin
      t.string  :value
    end

# PostgreSQL: "serial primary key"
# MySQL: "int(11) DEFAULT NULL auto_increment PRIMARY KEY"
# SQLite: "INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"

    # adapter_type = connection.adapter_name.downcase.to_sym
    # case adapter_type
    # when :mysql; execute "ALTER TABLE settings ADD PRIMARY KEY (id);"
    # when :mysql2; execute "ALTER TABLE settings ADD PRIMARY KEY (id);"
# #    when :sqlite; execute ""
# #    when :postgresql; execute "OOPS"
    # else; raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    #end
  end
  
  def down
    drop_table :plugins
    drop_table :settings
  end
  
end
