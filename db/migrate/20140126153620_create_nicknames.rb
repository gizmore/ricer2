class CreateNicknames < ActiveRecord::Migration
  def change
    create_table :server_nicks do |t|
      t.integer :server_id,  :null => false
      t.integer :sort_order, :null => false, :default => 0
      t.string  :nickname,   :null => false, :length => 64
      t.string  :hostname,   :null => false, :default => 'ricer.gizmore.org'
      t.string  :username,   :null => false, :default => 'Ricer'
      t.string  :realname,   :null => false, :default => 'Ricer IRC Bot'
      t.string  :password
      t.timestamps
    end
  end
end
