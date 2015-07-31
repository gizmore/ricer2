module Ricer::Plugins::Todo
  class Model::Entry < ActiveRecord::Base
    
    include Ricer::Base::Base

    self.table_name = 'todo_entries';
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table self.table_name do |t|
        t.string    :text,       :null => false
        t.integer   :priority,   :default => 0
        t.integer   :worker_id,  :null => false, :default => 0
        t.integer   :creator_id, :null => false
#        t.timestamp :done_at, :null => true,  :default => nil
        t.timestamp :deleted_at, :null => true,  :default => nil
        t.timestamps
      end
    end
    def self.upgrade_2
      m = ActiveRecord::Migration
      m.add_column self.table_name, :done_at, :datetime, :null => true, :null => true,  :default => nil, :after => :creator_id
    end

    scope :open, -> { where("#{table_name}.deleted_at IS NULL")}
    scope :closed, -> { where("#{table_name}.deleted_at IS NOT NULL")}
    
    def self.visible(user); where("deleted_at IS NULL"); end
  
    ##################
    ### Searchable ###
    ##################
    search_syntax do
      search_by :text do |scope, phrases|
        columns = [:text]
        scope.where_like(columns => phrases)
      end
    end

    ##################
    ### Connectors ###
    ##################
    def worker
      Ricer::Irc::User.find(self.worker_id) rescue nil
    end
    
    def creator
      Ricer::Irc::User.find(self.creator_id)
    end
    
    def displaydate
      I18n.l(self.created_at)
    end

    def displaytime
      lib.human_age(self.done_at)
    end

    def show_item()
      I18n.t!('.ricer.plugins.todo.show_item',
        id: self.id,
        text: self.text,
        creator: self.creator.displayname,
        date: self.displaydate
      )
    end
    
    def display_list_item(number)
      self.list_item(number)
    end

    def list_item(number)
      I18n.t('ricer.plugins.todo.list_item',
        id: number,
        text: self.text,
        creator: self.creator.displayname,
        date: self.displaydate,
        priority: self.priority
      )
    end

    def display_item(number)
      I18n.t('ricer.plugins.todo.display_item',
        n: number,
        id: self.id,
        text: self.text,
        creator: self.creator.displayname,
        date: self.displaydate,
        priority: self.priority
      )
    end
    
    def display_take(number=1)
      if self.deleted_at; key = 'deleted'
      elsif self.done_at; key = 'solved'
      elsif self.worker_id; key = 'taken'
      else; key = 'created'
      end
      # key = self.done_at.nil? ? 'taken' : 'solved'
      I18n.t("ricer.plugins.todo.#{key}_item",
        n: self.id,
        id: self.id,
        text: self.text,
        creator: self.creator.displayname,
        worker: self.worker.displayname,
        time: self.displaytime,
        priority: self.priority
      )
    end
    
  end
end    
