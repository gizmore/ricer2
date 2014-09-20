module Ricer::Plugins::Ai
  class Action < Ricer::Plugin
    
    trigger_is :action
    permission_is :owner
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    def execute(target, message)
      target.send_action(message)
    end
    
  end
end
