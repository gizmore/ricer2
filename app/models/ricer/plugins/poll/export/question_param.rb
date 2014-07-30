module Ricer::Plug::Params
  class QuestionParam < Base
    
    def convert_in!(input, options, message)
      Ricer::Plugins::Poll::Question.find(input) rescue failed_input
    end

    def convert_out!(question, options, message)
      question.text
    end
    
  end
end
