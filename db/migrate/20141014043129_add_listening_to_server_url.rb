class AddListeningToServerUrl < ActiveRecord::Migration
  def change
    
    add_column :server_urls, :listening, :boolean, :after => :peer_verify, :null => false, :default => false
    
  end
end
