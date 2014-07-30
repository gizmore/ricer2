module Ricer::Plugins::Poll
  class Answer < ActiveRecord::Base
    
    self.table_name = 'poll_answers'
    
    belongs_to :user,   :class_name => 'Ricer::Irc::User'
    belongs_to :option, :class_name => Option.name
    
    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.integer   :user_id,    :null => false
        t.integer   :option_id,  :null => false
        t.timestamp :created_at, :null => false
      end
    end
    
  end
end
