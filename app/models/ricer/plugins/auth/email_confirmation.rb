module Ricer::Plugins::Auth
  class EmailConfirmation < ActiveRecord::Base
    
    belongs_to :user, class_name: 'Ricer::Irc::User'
    
    validates :user, :presence => true  
    validates_as_email :email    
    
    def self.on_upgrade_1
      m = ActiveRecord::Migration
      m.drop_table table_name if connection.table_exists? table_name
      m.create_table table_name do |t|
        t.integer  :user_id,  :null => false
        t.string   :email,    :null => false
        t.string   :code,     :null => false, :length => 9
        t.datetime :valid_to, :null => false
      end
    end
    
    def self.cleanup
      where("valid_to < (?)", Time.now).delete_all
    end
    
    def self.new_confirmation(user, address, valid_for)
      new({
        user: user,
        email: address,
        code: Ricer::Irc::Setting.random_pin,
        valid_to: Time.now + valid_for,
      })
    end
    
  end
end
