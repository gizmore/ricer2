module Ricer::Plugins::Ai
  class Action < Ricer::Plugin
    
    trigger_is :action
    permission_is :halfop
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    def execute(target, text)
      target.send_action(text)
    end
    
  end
end
