module Ricer::Plugins::Note
  class Message < ActiveRecord::Base
    
    self.table_name = :note_messages
    
    belongs_to :sender, :class_name => 'Ricer::Irc::User'
    belongs_to :receiver, :class_name => 'Ricer::Irc::User'
    
    def self.inbox(user); where(receiver_id: user.id); end
    def self.outbox(user); where(sender_id: user.id); end
    def self.visible(user); where("#{table_name}.sender_id=#{user.id} OR #{table_name}.receiver_id=#{user.id}"); end
    def self.unread; where("#{table_name}.read_at IS NULL"); end
    def self.read; where("#{table_name}.read_at IS NOT NULL"); end
    
    def self.on_upgrade_1
      m = ActiveRecord::Migration
      m.create_table table_name do |t|
        t.integer   :sender_id,    :null => false
        t.integer   :receiver_id,  :null => true
        t.string    :message,      :null => false, :length => 1024
        t.datetime  :read_at,      :null => true
        t.datetime  :sent_at,      :null => false
      end
    end
    
    search_syntax do
      search_by :text do |scope, phrases|
        scope.joins(:sender).where_like(['users.nickname', :message] => phrases)
      end
      search_by :sender do |scope, phrases|
        scope.joins(:sender).where_like(['users.nickname'] => phrases)
      end
      search_by :sender do |scope, phrases|
        scope.joins(:receiver).where_like(['users.nickname'] => phrases)
      end
      search_by :message do |scope, phrases|
        scope.where_like([:message] => phrases)
      end
      search_by :id do |scope, phrases|
        scope.where([:id] => phrases)
      end
    end

    def display_list_item(number)
      I18n.t('ricer.plugins.note.list_item', id: number, from: self.sender.display_name, unread: unread_bold)
    end
    
    def unread_bold
      self.read? == false ? Ricer::Irc::Lib::BOLD : '' 
    end

    def display_show_item(number)
      mark_read
      I18n.t('ricer.plugins.note.view_item', id: number, from: self.sender.display_name, date: self.display_date, message: self.text)
    end
    
    def mark_read
      self.read_at = Time.now
      self.save!
    end
    
    def display_date
      I18n.l(self.sent_at)
    end
    
  end
end