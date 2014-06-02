module Ricer::Plugins::Ai
  class Notice < Ricer::Plugin
    
    trigger_is :notice
    permission_is :halfop
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    def execute(target, text)
      target.send_notice(text)
    end
    
  end
end
