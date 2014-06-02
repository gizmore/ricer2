module Ricer::Plugins::Ai
  class Message < Ricer::Plugin
    
    trigger_is :message
    permission_is :halfop
    
    has_usage :execute, '<user> <..message..>'
    has_usage :execute, '<channel> <..message..>'
    def execute(target, text)
      target.send_message(text)
    end
    
  end
end
