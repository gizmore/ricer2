module Ricer::Irc::Mode
  class ChanMode < Mode
    
    attr_reader :permission
    
    def initialize(permissions=0)
      @permission = Ricer::Irc::Permission.by_permission(permissions)
    end
    
    def authenticated=(boolean)
      @permission.authenticated = boolean
    end
    
    def mode_changed
      @permission = Ricer::Irc::Permission.by_permission(permissions_from_mode)
      bot.log_debug("ChanMode#mode_changed: #{@permission.display}")
      self
    end
    
  end
end
