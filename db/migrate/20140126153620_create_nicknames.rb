class CreateNicknames < ActiveRecord::Migration
  def change
    create_table :server_nicks do |t|
      t.integer :server_id,  :null => false
      t.string  :nickname,   :null => false, :length => 64
      t.string  :hostname,   :null => false, :default => Rails.configuration.ricer_hostname
      t.string  :username,   :null => false, :default => Rails.configuration.ricer_nickname
      t.string  :realname,   :null => false, :default => Rails.configuration.ricer_realname
      t.string  :password
      t.timestamps
    end
  end
end
