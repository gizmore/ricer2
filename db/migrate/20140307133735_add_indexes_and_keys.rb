class AddIndexesAndKeys < ActiveRecord::Migration
  
  def change
    
    add_index :users, :nickname, name: :users_nickname_index
    add_index :users, :server_id, name: :users_server_index
    add_foreign_key :users, :servers, :dependent => :delete
    add_foreign_key :users, :locales
    add_foreign_key :users, :encodings
    add_foreign_key :users, :timezones

    add_foreign_key :server_urls, :servers, :dependent => :delete

    add_index :channels, :name, name: :channels_name_index
    add_index :channels, :server_id, name: :channels_server_index
    add_foreign_key :channels, :servers, :dependent => :delete
    add_foreign_key :channels, :locales
    add_foreign_key :channels, :encodings
    add_foreign_key :channels, :timezones
    
    add_foreign_key :server_nicks, :servers, :dependent => :delete
    
    add_index :chanperms, :user_id, name: :chanperms_user_index
    add_foreign_key :chanperms, :users, :dependent => :delete
    add_foreign_key :chanperms, :channels, :dependent => :delete
    
  end
  
end