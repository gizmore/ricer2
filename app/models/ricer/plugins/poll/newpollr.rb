module Ricer::Plugins::Poll
  class Newpollr < NewpollBase
    
    trigger_is :'+hotornot'

    has_usage :execute, '<..question..>'
    def execute(question)
      question = Question.create!({
        text: question,
        user_id: sender.id,
        poll_type: Question::RATE,
      })
      announce(question)
    end

  end
end
