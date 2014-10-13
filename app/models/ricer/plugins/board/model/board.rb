module Ricer::Plugins::Board
  class Model::Board < ActiveRecord::Base

    self.table_name = :wechall_boards
    
    include Ricer::Base::Base
    
    abbonementable_by([Ricer::Irc::User, Ricer::Irc::Channel])

    validates :name, named_id: true
    validates :url,  uri: { ping: false, trust: false, connect: true, exist: true, schemes: [:http,:https] }
    validate  :url_has_limit_and_date

    scope :enabled, -> { where("#{table_name}.deleted_at IS NULL") }
    scope :disabled, -> { where("#{table_name}.deleted_at IS NOT NULL") }

    def self.upgrade_1
      m = ActiveRecord::Migration.new
      m.create_table table_name do |t|
        t.string    :name,         :null => false, :length => NamedId.maxlen,   :unique => true, :charset => :ascii, :collation => :ascii_bin
        t.string    :url,          :null => false, :unique => true
        t.integer   :last_thread,  :null => false, :default => 0
        t.timestamp :checked_at,   :null => true,  :default => nil
        t.timestamp :deleted_at,   :null => true,  :default => nil
        t.timestamps
      end
    end
    
    def url_has_limit_and_date
      errors[:url] = "does not contain :DATE:" unless self.url.index(':DATE:')
      errors[:url] = "does not contain :LIMIT:" unless self.url.index(':LIMIT:')
    end
    
    def epoch
      self.checked_at = Time.new(2010, 12, 31)
    end
    
    def gdo_date
      lib.gdo_date(self.checked_at||epoch)
    end
    
    def replaced_url
      self.url.gsub(':DATE:', gdo_date).gsub(':LIMIT:', '5')
    end
    
    def test_protocol
      entries = fetch_entries!
      return false if entries.length < 1
      entries
    end
    
    def fetch_entries
      fetch_entries! rescue []
    end
    
    def fetch_entries!
      bot.log_debug("Checking WeChall Board: #{self.replaced_url}")
      parse_content(open(self.replaced_url))
    end
    
    def parse_content(content)
      announcements = []
      content.string.split("\n").each do |line|
        unless line.trim!.empty?
          announcement = parse_line(line)
          announcements.push(announcement) if announcement
        end
      end
      clean_announcements(announcements)
    end
    
    def clean_announcements(announcements)
      delete = []
      deleting = true
      announcements.each{|a| self.checked_at = a.date if a.date > self.checked_at }
      announcements.each do |a|
        if deleting
          if a.date == self.checked_at
            delete.push(a)
            if (a.thread == self.last_thread)
              deleting = false
            end
          end
        end
      end
      delete.each{|d|announcements.delete(d)} and  announcements
    end
    
    def unescape(s)
      s.gsub('\\:', ':')
    end
    
    def parse_line(line)
      parts = line.split("::")
      raise StandardError.new("Line has invalid number of parts: #{line}") if parts.length != 6
      # Map the parts
      parts.map!{|s| unescape(s) }
      parts[0] = parts[0].to_i; parts[2] = parts[2].to_i
      parts[1] = lib.ruby_date(parts[1])
      # End of maps
      # OLD:NEW
      parts[1] < self.checked_at ?
        nil :
        Model::Announcement.new(parts)
    end
    
  end
end
