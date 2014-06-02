# t.integer  "server_id",                                null: false
# t.integer  "sort_order", default: 0,                   null: false
# t.string   "nickname",                                 null: false
# t.string   "hostname",   default: "ricer.gizmore.org", null: false
# t.string   "username",   default: "Ricer",             null: false
# t.string   "realname",   default: "Ricer IRC Bot",     null: false
# t.string   "password"
# t.datetime "created_at"
# t.datetime "updated_at"
module Ricer::Irc
  class ServerNick < ActiveRecord::Base
    
    scope :sorted, -> { order('server_nicks.sort_order ASC') }
    
    def name
      next_nickname
    end
    
    def next_nickname
      self.nickname + (@cycle||'')
    end
    
    def next_cycle(cycle)
      @cycle = cycle
    end
    
    def reset_cycle
      next_cycle('')
    end
    
    def can_authenticate?
      (self.password != nil) && (@cycle.empty?)
    end
    
  end
end
