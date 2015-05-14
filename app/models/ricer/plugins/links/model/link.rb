module Ricer::Plugins::Links
  class Model::Link < ActiveRecord::Base
    
    acts_as_votable
    
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    belongs_to :channel, :class_name => 'Ricer::Irc::Channel'
    
    ###############
    ### Install ###
    ###############    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table table_name do |t|
        t.string    :url,          :null => false
        t.integer   :user_id,      :null => false
        t.integer   :channel_id,   :null => true
        t.string    :mime_type,    :null => false, :length => 128, :charset => :ascii
        t.integer   :added,        :null => false, :default => 0
        t.timestamps
      end
    end
    
    #################
    ### Directory ###
    #################
    def root_dir; "#{Rails.root}/files/links"; end

    def cleardir; rmdir && mkdir; end

    def mkdir
      dir = self.root_dir
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
    
    def rmdir
      dir = self.root_dir
      FileUtils.remove_dir(dir) if File.directory?(dir)
    end
 
 
  end
end