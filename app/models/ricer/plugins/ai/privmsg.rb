module Ricer::Plugins::Ai
  class Privmsg < Ricer::Plugin
    
    trigger_is :privmsg
    permission_is :halfop
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    def execute(target, text)
      target.send_privmsg(text)
    end
    
  end
end
