class CreateChanperms < ActiveRecord::Migration
  def change
    create_table :chanperms do |t|
      t.integer   :user_id,     :null => false
      t.integer   :channel_id,  :null => false
      t.integer   :permissions, :null => false,  :default => 0
      t.boolean   :online,      :null => false,  :default => false
      t.timestamp :created_at,  :null => false
    end
  end
end
