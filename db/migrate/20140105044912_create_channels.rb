class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.integer :server_id
      t.string  :name
      t.string  :triggers,    :default => nil,   :null => true,   :length => 4
      t.integer :locale_id,   :default => 1,     :null => false
      t.integer :timezone_id, :default => 1,     :null => false
      t.integer :encoding_id, :default => 1,     :null => false
      t.boolean :colors,      :default => true
      t.boolean :decorations, :default => true
      t.boolean :online,      :default => false, :null => false
      t.timestamps
    end
  end
end
