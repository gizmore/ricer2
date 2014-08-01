module Ricer::Plugins::Cvs
  class Permission < ActiveRecord::Base
    
    self.table_name = :cvs_repo_perms
    
    belongs_to :repo, :class_name => Repo.name
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    
    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer :repo_id, :null => false
        t.integer :user_id, :null => false
      end
    end
    
  end
end
