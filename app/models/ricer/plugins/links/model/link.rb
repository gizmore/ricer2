module Ricer::Plugins::Links
  class Model::Link < ActiveRecord::Base
    
    acts_as_votable
    
    belongs_to :user,      :class_name => 'Ricer::Irc::User'
    belongs_to :channel,   :class_name => 'Ricer::Irc::Channel'
    belongs_to :mime_type, :class_name => 'Mime::Type'
    
    ###############
    ### Install ###
    ###############    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table table_name do |t|
        t.string    :url,          :null => false
        t.integer   :user_id,      :null => false
        t.integer   :channel_id,   :null => true
        t.integer   :mime_type_id, :null => true
        t.integer   :added,        :null => false, :default => 0
        t.timestamp :created_at
      end
    end
    
    

  end
end