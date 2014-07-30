module Ricer::Plugins::Poll
  class Newpoll < NewpollBase
    
    trigger_is :'+poll'

    has_usage :execute, '<..question|answer1|answer2|..>'
    def execute(message)
      create_poll(message, Question::POLL)
    end

  end
end
