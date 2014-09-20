module Ricer::Plugins::Ai
  class Say < Ricer::Plugin
    
    trigger_is :say
    permission_is :owner
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    
    def execute(target, message)
      target.send_privmsg(message)
    end
    
  end
end
