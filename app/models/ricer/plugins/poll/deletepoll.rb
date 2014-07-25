module Ricer::Plugins::Poll
  class Deletepoll < Ricer::Plugin
    
    trigger_is :'-poll'

    has_usage :execute, '<poll>'
    def execute(poll)
      

    end

  end
end
