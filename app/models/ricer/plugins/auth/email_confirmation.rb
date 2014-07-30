module Ricer::Plugins::Auth
  class EmailConfirmation < ActiveRecord::Base
    
    # Relations
    belongs_to :user, class_name: 'Ricer::Irc::User'
    scope :not_expired, -> { where('expires > ?', Time.now) }

    # Validators    
    validates :user, :presence => true
    validates_as_email :email

    # Cleanup once in a while    
    after_commit -> { self.class.all.where("expires < ?", Time.now).delete_all }

    # Table layout in ricer plugin style 
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.drop_table table_name if connection.table_exists? table_name
      m.create_table table_name do |t|
        t.integer   :user_id, :null => false
        t.string    :email,   :null => false
        t.string    :code,    :null => false, :length => 9
        t.timestamp :expires, :null => false
      end
    end
    
  end
end
