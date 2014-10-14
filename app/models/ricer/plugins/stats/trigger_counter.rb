module Ricer::Plugins::Stats
  class TriggerCounter < ActiveRecord::Base
    
    belongs_to :plugin, :class_name => 'Ricer::Irc::Plugin'
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    
    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer :plugin_id, :null => false
        t.integer :user_id,   :null => false
        t.integer :calls,     :null => false, :default => 0
      end
      m.add_index table_name, :plugin_id, name: :plugin_calls_index
      m.add_index table_name, [:plugin_id, :user_id], unique: true, name: :plugin_user_calls_index
      m.add_foreign_key table_name, :users, dependent: :delete
      m.add_foreign_key table_name, :plugins, dependent: :delete
    end
    
    scope :summed, -> { select("SUM(#{table_name}.calls) AS sum") }
    scope :for_user, lambda { |user| where(:user => user) }
    scope :for_plugin, lambda { |plugin| where(:plugin_id => plugin.id) }
    
    def self.count(plugin_id, user_id)
      counter = where(:plugin_id => plugin_id, :user_id => user_id).first
      counter = new({:plugin_id => plugin_id, :user_id => user_id, :calls => 0}) if counter.nil?
      counter[:calls] += 1
      counter.save!
      counter
    end
    
  end
end
