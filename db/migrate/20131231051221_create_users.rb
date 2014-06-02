class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer  :server_id,       :null => false
      t.integer  :permissions,     :default => 0, :null => false
      t.string   :nickname,        :null => false, :length => 64
      t.string   :hashed_password, :length  => 128
      t.string   :email                              
      t.string   :message_type,    :default => 'n',   :null => false, :length => 1
      t.string   :gender,          :default => 'm',   :null => false, :length => 1
      t.integer  :locale_id,       :default => 1,     :null => false
      t.integer  :encoding_id,     :default => 1,     :null => false
      t.integer  :timezone_id,     :default => 1,     :null => false
      t.boolean  :online,          :default => false, :null => false
      t.timestamps
    end
  end
end
