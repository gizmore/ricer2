module Ricer::Plugins::Seen
  class Entry < ActiveRecord::Base
    
    self.table_name = :seen_entries
    
    def user; Ricer::Irc::User.find(self.user_id); end
    def channel; self.channel_id ? Ricer::Irc::Channel.find(self.channel_id) : nil; end

    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer :user_id,    :null => false, :unsigned => true
        t.integer :channel_id, :null => false, :unsigned => true
        t.string  :message,    :null => false
      end
    end
    
  end
end
