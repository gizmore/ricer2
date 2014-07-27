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
    
    NOTICE = 'n'
    PRIVMSG = 'p'
    
    belongs_to :locale
    belongs_to :timezone
    belongs_to :encoding
    
    with_global_orm_mapping
    def should_cache?; self.online == true; end
    
    def name; self.nickname; end
    def displayname; Ricer::Irc::Lib.instance.no_highlight(self.nickname); end
    def guid; "#{self.name}:#{self.server_id}"; end
    def server; Ricer::Bot.instance.servers.find(self.server_id); end
    
    def self.current; Thread.current[:ricer_user]; end
    def self.current=(user); Thread.current[:ricer_user] = user; end

    scope :online, -> { where(:online => 1) }
    
    def get_queue; server.connection.queue_for(self); end
    def flush_queue; server.connection.flush_queue_for(self); end

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
    
    #################
    ### Chanperms ###
    #################
    def all_chanperms
      Ricer::Irc::Chanperm.where(:user_id => self.id).load
    end
    
    def chanperm_for(channel)
      Ricer::Irc::Chanperm.where({:user_id => self.id, :channel_id => channel.id}).first_or_create
    end
    
    def permission
      Ricer::Irc::Permission.by_permission(self.permissions, authenticated?)
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
    def registered?; self.hashed_password != nil; end
    
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
