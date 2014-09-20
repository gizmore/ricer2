module Ricer::Plugins::Ai
  class Notice < Ricer::Plugin
    
    trigger_is :notice
    permission_is :owner
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    def execute(target, message)
      target.send_notice(message)
    end
    
  end
end
