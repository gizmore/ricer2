module Ricer::Plugins::Rss
  class Feed < ActiveRecord::Base
    
    require 'rss'
    require 'open-uri'
    
    URL_LEN = 32
    NAME_LEN = 32
    TITLE_LEN = 96
    DESCR_LEN = 255
    
    abbonementable_by([Ricer::Irc::User, Ricer::Irc::Channel])

    belongs_to :user, :class_name => 'Ricer::Irc::User'
    
    validates :name, named_id:true
    validates :url,  uri: { ping:false, exists:false, shemes:[:http, :https] }

    def self.visible(user); self.enabled; end
    def self.enabled; where('feeds.deleted_at IS NULL'); end
    def self.deleted; where('feeds.deleted_at IS NOT NULL'); end
    
    def self.upgrade_1
      m = ActiveRecord::Migration
      m.create_table :feeds do |t|
        t.integer   :user_id,     :null => false
        t.string    :name,        :null => false, :length => NamedId.maxlen,   :unique => true
        t.string    :url,         :null => false, :length => UriColumn.maxlen, :unique => true
        t.string    :title,       :null => true,  :length => TITLE_LEN
        t.string    :description, :null => true,  :length => DESCR_LEN
        t.integer   :updates,     :null => false, :default => 0
        t.datetime  :checked_at
        t.datetime  :deleted_at
        t.timestamps
      end
      m.add_index :feeds, :name, :name => :feeds_name_index
      m.add_foreign_key :feeds, :users
    end

    search_syntax do
      search_by :text do |scope, phrases|
        columns = [:url, :name, :title, :description]
        scope.where_like(columns => phrases)
      end
    end
      
    def self.by_id(id)
      where(:id => id).first
    end
    def self.by_url(url)
      where(:url => url).first
    end
    def self.by_name(name)
      where(:name => name).first
    end
    def self.by_arg(arg)
      by_id(arg) || by_name(arg)
    end

    def display_show_item(number)
      I18n.t('ricer.plugins.rss.show_item', id:self.id, name:self.name, title:self.title, description:self.description);
    end
    
    def display_list_item(number)
      I18n.t('ricer.plugins.rss.list_item', id:self.id, name:self.name)
    end
    
    def nohtml(string, maxlen)
      Ricer::Irc::Lib.instance.strip_html(string)[0..maxlen-1]
    end
    
    def working?
      begin
        open(url) do |rss|
          feed = RSS::Parser.parse(rss)
          Ricer::Bot.instance.log_debug feed
          self.title = feed_title(feed)
          self.description = feed_descr(feed)
          self.checked_at = feed_date(feed)
        end
        return (self.title != nil) && (self.checked_at != nil)
      rescue StandardError => e
        puts e
        puts e.backtrace
        return false
      end
    end
    
    def check_feed(plugin)
      begin
        open(url) do |rss|
          feed = RSS::Parser.parse(rss)
          collect = []
          feed.items.each do |item|
#            puts item
            collect.push(item) if item.pubDate > self.checked_at
          end
          feed_has_news(plugin, feed, collect) unless collect.empty?
        end
      rescue StandardError => e
        puts e
        puts e.backtrace
      end
    end
    
    def feed_title_text(feed)
      if feed.channel
        return feed.channel.title if feed.channel.title 
      end
      return feed.title if feed.title
    end

    def feed_title(feed)
      text = feed_title_text(feed)
      return nohtml(text, TITLE_LEN) if text
    end
    
    def feed_descr_text(feed)
      return feed.channel.description if feed.channel && feed.channel.description
      return feed.subtitle if feed.subtitle
    end
    
    def feed_descr(feed)
      text = feed_descr_text(feed)
      nohtml(text, DESCR_LEN) if text
    end
    
    def feed_date(feed)
      if feed.channel
        c = feed.channel
        return c.pubDate if c.pubDate
        return c.lastBuildDate if c.lastBuildDate
      end
      return feed.updated if feed.updated
    end
    
    def feed_has_news(plugin, feed, items)
      announce_news(plugin, items)
      self.title = feed_title(feed)
      self.description = feed_descr(feed)
      self.checked_at = items[-1].pubDate # feed_date(feed)
      self.updates = self.updates + items.length
      self.save!
    end
    
    def announce_news(plugin, items)
      items.reverse!
      abbonements.each do |abbonement|
        abbonement.target.localize!
        items.each do |item|
          abbonement.target.send_privmsg(feedmessage(plugin, item))
        end
      end
    end
    
    def feedmessage(plugin, item)
      link = item.link == nil ? item.description : item.link
      I18n.t('ricer.plugins.rss.msg_got_news', name:name, title:item.title, link:link)
    end
    
  end
end
