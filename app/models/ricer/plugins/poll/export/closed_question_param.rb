module Ricer::Plug::Params
  class ClosedQuestionParam < Base
    
    def convert_in!(input, options, message)
      Ricer::Plugins::Poll::Question.closed.find(input) rescue fail(:err_not_closed)
    end

    def convert_out!(question, options, message)
      question.text
    end
    
  end
end
