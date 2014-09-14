# t.integer  "user_id",                     null: false
# t.integer  "channel_id",                  null: false
# t.integer  "permissions", default: 0,     null: false
# t.boolean  "online",      default: false, null: false
# t.datetime "created_at",                  null: false
module Ricer::Irc
  class Chanperm < ActiveRecord::Base
    
    with_global_orm_mapping
    def should_cache?; self.online == true; end
    
    attr_reader :chanmode
    
    belongs_to :user, :class_name => 'Ricer::Irc::User'
    belongs_to :channel, :class_name => 'Ricer::Irc::Channel'
    
    def ricer_on_joined_channel(user, permissions)
      @chanmode = Ricer::Irc::Mode::ChanMode.new(permissions)
    end
    
    def permission
      @chanmode.permission
    end
    
    def authenticated=(boolean)
      @chanmode.authenticated = boolean
    end
    
    def merged_permission
      permission.merge(Ricer::Irc::Permission.by_permission(self.permissions))
    end
    
  end
end
