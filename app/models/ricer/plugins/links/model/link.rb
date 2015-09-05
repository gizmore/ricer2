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
      m.drop_table table_name if connection.table_exists? table_name
      m.create_table table_name do |t|
        t.string    :url,          :null => false
        t.string    :title,        :null => true
        t.integer   :user_id,      :null => false
        t.integer   :channel_id,   :null => true
        t.string    :hash,         :null => false, :length => Ricer::Hash.LENGTH
        t.string    :mime_type,    :null => false, :length => 128, :charset => :ascii
        t.integer   :added,        :null => false, :default => 0
        t.timestamps
      end
      self.mkdir
    end

    #################
    ### Directory ###
    #################
    def self.root_dir; "#{Rails.root}/files/images"; end

    def self.cleardir; rmdir && mkdir; end

    def self.mkdir
      dir = self.root_dir
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
    
    def self.rmdir
      dir = self.root_dir
      FileUtils.remove_dir(dir) if File.directory?(dir)
    end
    
    def today
      self.created_at.strftime("%Y%m%d")
    end
    
    def today_dir
      "#{self.class.root_dir}/#{today}"
    end
       
    def mkdir_today
      dir = today_dir
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
    
    def dir_today
      mkdir_today
      today_dir
    end
    
    ##################
    ### Save image ###
    ##################
    def image_filename
      "#{self.id}-#{self.clean_title}"
    end
    
    def clean_title
      self.title.gsub(/[^-a-z_0-9.,]/, '')
    end
    
    def image_path
      "#{self.dir_today}/#{image_filename}"
    end

    def save_image(image_data)
      mkdir_today
      File.open(image_path, "wb") do |f|
        f.write(image_data)
      end
    end
    
  end
end
