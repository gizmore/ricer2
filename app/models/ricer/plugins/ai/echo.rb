module Ricer::Plugins::Ai
  class Echo < Ricer::Plugin
    
    trigger_is :echo
    permission_is :voice
    
    has_usage :execute, '<..message..>'
    def execute(text)
      reply text
    end
    
  end
end
