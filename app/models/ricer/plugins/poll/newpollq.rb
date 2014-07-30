module Ricer::Plugins::Poll
  class Newpollq < NewpollBase
    
    trigger_is :'+question'

    has_usage :execute, '<..question..>'
    def execute(question)
      question = Question.create!({
        text: question,
        user_id: sender.id,
        poll_type: Question::QUESTION,
      })
      announce(question)
    end

  end
end
