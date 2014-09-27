class AddPasswordToChannels < ActiveRecord::Migration
  def change
    
    add_column :channels, :password, :string, :after => :name, :limit => 64, :null => true, :default => nil
    
  end
end
