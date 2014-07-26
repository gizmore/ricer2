module Ricer::Plugins::Poll
  class Votepoll < Ricer::Plugin
    
    trigger_is :'votepoll'

    has_usage :execute, '<poll> <string>'
    def execute(poll, answer)

    end

  end
end
