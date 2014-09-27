# t.integer  "server_id",                       null: false
# t.integer  "permissions",     default: 0,     null: false
# t.string   "nickname",                        null: false
# t.string   "hashed_password"
# t.string   "email"
# t.string   "message_type",    default: "n",   null: false
# t.string   "gender",          default: "m",   null: false
# t.integer  "locale_id",       default: 1,     null: false
# t.integer  "encoding_id",     default: 1,     null: false
# t.integer  "timezone_id",     default: 1,     null: false
# t.boolean  "online",          default: false, null: false
# t.boolean  "bot",             default: false, null: false
# t.datetime "created_at"
# t.datetime "updated_at"
module Ricer::Irc
  class User < ActiveRecord::Base
    
    include Ricer::Base::Base
    include Ricer::Base::Translates
    
    NOTICE = 'n'
    PRIVMSG = 'p'
    
    belongs_to :server
    belongs_to :locale
    belongs_to :timezone
    belongs_to :encoding
    
    with_global_orm_mapping
    def should_cache?; self.online == true; end
    def global_cache_key; "#{self.nickname.downcase}:#{self.server_id}"; end
    
    def name; self.nickname; end
    def quietname; Ricer::Irc::Lib.instance.no_highlight(self.nickname); end
    def displayname; "\x02#{quietname}\x02:#{self.server_id}" end
    def guid; "#{self.name}:#{self.server_id}"; end
    def is_ricer?; self.server.nickname.name.downcase == self.nickname.downcase; end

    # Current user for current thread
    def self.current; Thread.current[:ricer_user]; end
    def self.current=(user); Thread.current[:ricer_user] = user; end

    scope :bot, -> { where(:bot => false) }
    scope :human, -> { where(:bot => false) }
    scope :online, -> { where(:online => true) }
    scope :offline, -> { where(:online => false) }
    scope :joined, ->(channel) { joins(:chan_perms).where('chan_perms.channel_id=?', channel) }
    
    def get_queue; server.connection.queue_for(self); end
    def flush_queue; server.connection.flush_queue_for(self); end
    
    def usermode; @user_mode; end
    
    #########################
    ### Memory Management ###
    #########################
    def ricer_on_joined_server(server)
      self.online = true
      self.save!
      global_cache_add
      @user_mode = Ricer::Irc::Mode::UserMode.new
    end

    def ricer_on_parted_server(server)
      self.online = false
      self.save!
      global_cache_remove
      all_chanperms.update_all(:online => false)
      all_chanperms.each do |chanperm|
        chanperm.global_cache_remove
      end
    end
    
    def ricer_on_joined_channel(channel, permissions=0)
      perm = chanperm_for(channel)
      perm.online = true
      perm.save!
      perm.global_cache_add
      perm.ricer_on_joined_channel(self, permissions)
    end

    def ricer_on_parted_channel(channel)
      perm = chanperm_for(channel)
      perm.online = false
      perm.save!
      perm.global_cache_remove
    end
    
    #############
    ### Prefs ###
    #############
    def wants_notice?; self.message_type == NOTICE; end
    def wants_privmsg?; self.message_type == PRIVMSG; end

    #####################
    ### Communication ###
    #####################
    def localize!; I18n.locale = self.locale; Time.zone = self.timezone.iso; self; end
    def send_action(text); server.action_to(self, text); end
    def send_message(text); wants_notice? ? send_notice(text) : send_privmsg(text); end
    def send_notice(text); server.notice_to(self, text); end
    def send_privmsg(text); server.privmsg_to(self, text); end
    
    ###########################
    ### Channel permissions ###
    ###########################
    # Get all permission objects
    def all_chanperms
      Ricer::Irc::Chanperm.where(:user_id => self.id)
    end
    
    # Get permission object
    def chanperm_for(channel)
      Ricer::Irc::Chanperm.
        create_with(:permission => self.permission).
        find_or_create_by(:user_id => self.id, :channel_id => channel.id)
    end
    
    # Check for channel against other permission object 
    def has_channel_permission?(channel, permission)
      perm = chanperm_for(channel)
      perm.permission.has_permission?(permission, perm.channel_permission)
    end
    
    ##########################
    ### Server permissions ###
    ##########################
    # Get permission object
    def permission
      Ricer::Irc::Permission.by_permission(self.permissions, authenticated?)
    end
    
    # Check by permission object
    def has_permission?(permission)
      self.permission.has_permission?(permission)
    end

    # Check by privchar (prlvhosmafixy)
    def has_permission_char?(permchar)
      has_permission?(Ricer::Irc::Permission.by_char(permchar))
    end
    
    ################
    ### Hostmask ###
    ################
    def hostmask
      @hostmask
    end
    
    def hostmask=(hostmask)
      if hostmask && (@hostmask != hostmask)
        bot.log_info("Logged you out because of your hostmask #{@hostmask} != #{hostmask}")
        @hostmask = hostmask
        logout! if @authenticated
      end
      self
    end

    ######################
    ### Authentication ###
    ######################
    def authenticate!(password)
      return @authenticated = false unless registered?
      login! if BCrypt::Password.new(self.hashed_password).is_password?(password)
    end
    
    def login!
      set_authed true
    end

    def logout!
      set_authed false
    end

    def set_authed(bool)
      @authenticated = bool
      Ricer::Irc::Chanperm.where(:user_id => self.id, :online => true).each do |chanperm|
        chanperm.authenticated = bool
      end
    end

    def authenticated?; @authenticated == true; end
    def registered?; !!self.hashed_password; end
    
    def password=(new_password)
      first_time = !self.registered?
      self.hashed_password = BCrypt::Password.create(new_password)
      self.save!
      register if first_time
    end
    
    private

    def register
      bits = Permission::REGISTERED.bit|Permission::AUTHENTICATED.bit
      self.permissions |= bits
      self.save!
      all_chanperms.each do |chanperm|
        chanperm.permissions |= bits
        chanperm.save!
      end
    end
    
  end
end
