class AddEncodingToServers < ActiveRecord::Migration
  def change
    add_column :servers, :encoding_id, :integer, :null => false, :default => 1, :after => :connector
    add_foreign_key :servers, :encodings, :name => :server_encodings
    change_column :users, :encoding_id, :integer, :null => true, :default => nil
    change_column :channels, :encoding_id, :integer, :null => true, :default => nil
  end
end
