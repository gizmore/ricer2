# t.integer  "user_id",                     null: false
# t.integer  "channel_id",                  null: false
# t.integer  "permissions", default: 0,     null: false
# t.boolean  "online",      default: false, null: false
# t.datetime "created_at",                  null: false
module Ricer::Irc
  class Chanperm < ActiveRecord::Base
    
    with_global_orm_mapping
    def should_cache?; true; end
    def global_cache_key; "#{self.user.id}:#{self.channel.id}"; end
    
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    belongs_to :channel, :class_name => 'Ricer::Irc::Channel'
    
    def ricer_on_joined_channel(user, permissions)
      @chanmode = Ricer::Irc::Mode::ChanMode.new(permissions)
    end
    
    def chanmode
      @chanmode ||= Ricer::Irc::Mode::ChanMode.new(0)
    end
    
    def user_permission
      user.permission
    end
    
    def channel_permission
      chanmode.permission
    end
    
    def ricer_permission
      Ricer::Irc::Permission.by_permission(self.permissions, authenticated?)
    end
    
    def authenticated?
      user.authenticated?
    end
    
    def authenticated=(boolean)
      chanmode.authenticated = boolean
    end
    
    def permission_bits
      self.permissions | user.permissions | chanmode.permission.bit      
    end
    
    def permission
      Permission.by_permission(permission_bits, authenticated?)
    end
    
  end
end
