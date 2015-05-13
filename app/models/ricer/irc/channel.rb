# t.integer :server_id
# t.string  :name
# t.string  :password
# t.string  :triggers,    :default => nil,   :null => true,  :length => 4
# t.integer :locale_id,   :default => 1,     :null => false
# t.integer :timezone_id, :default => 1,     :null => false
# t.integer :encoding_id, :default => 1,     :null => false
# t.boolean :colors,      :default => true
# t.boolean :decorations, :default => true
# t.boolean :online,      :default => false, :null => false
# t.timestamps
module Ricer::Irc
  class Channel < ActiveRecord::Base
    
    with_global_orm_mapping
    def should_cache?; self.online == true; end
    def global_cache_key; "#{self.name.downcase}:#{self.server_id}"; end
    
    belongs_to :server
    belongs_to :locale
    belongs_to :timezone
    belongs_to :encoding

    scope :online, -> { where(:online => 1) }
    
    ###############
    ### Display ###
    ###############
    def guid
      "#{self.name}:#{self.server_id}"
    end

    def displayname
      @_displayname || _displayname
    end
    
    def _displayname
      b = self.online ? "\x02" : ''
      @_displayname = "#{b}#{self.name}#{b}:#{self.server.name}"
    end
    
    #########################
    ### Memory Management ###
    #########################
    def ricer_on_join
      unless self.online
        self.online = true
        self.save!
        global_cache_add
        @chan_mode = Ricer::Irc::Mode::ChanMode.new
      end
    end
    
    def ricer_on_part
      self.online = false
      self.save!
      global_cache_remove
    end
    
    def users
      User.joined(self)
    end

    #####################
    ### Communication ###
    #####################
    def localize!; I18n.locale = self.locale.iso; Time.zone = self.timezone.iso; self; end
    def send_action(text); server.action_to(self, text); end
    def send_message(text); server.privmsg_to(self, text); end
    def send_notice(text); server.notice_to(self, text); end
    def send_privmsg(text); server.privmsg_to(self, text); end

  end
end
