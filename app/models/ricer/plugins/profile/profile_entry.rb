module Ricer::Plugins::Profile
  class ProfileEntry < ActiveRecord::Base
    
    def self.column_names
      ProfileEntry.column_names - [:id, :user_id, :created_at, :updated_at]
    end
    
    def self.valid_field?(field)
      self.column_names.inlcude?(field)
    end
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table :profile_entries do |t|
        t.integer   :user_id,  :null => false
        t.integer   :age
        t.string    :gender, :length => 1
        t.date      :birthdate
        t.string    :country, :length => 2
        t.string    :about, :length => 128
        t.string    :phone, :length => 32
        t.string    :mobile, :length => 32
        t.string    :icq, :length => 12
        t.string    :skype, :length => 48
        t.string    :jabber, :length => 64
        t.string    :threema, :length => 32
        t.timestamps
      end
      m.add_index :profile_entries, :user_id, :name => :profile_user_index
      m.add_foreign_key :profile_entries, :users, :dependent => :delete
    end

  end
end
