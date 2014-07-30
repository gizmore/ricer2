module Ricer::Plugins::Poll
  class Newpollm < NewpollBase
    
    trigger_is :'+multiplechoice'

    has_usage :execute, '<..question|option1|option2|..>'
    def execute(message)
      
      create_poll(message, Question::MULTI)
      
    end

  end
end
