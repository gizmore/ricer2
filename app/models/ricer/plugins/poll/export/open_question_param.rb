module Ricer::Plug::Params
  class OpenQuestionParam < Base
    
    def convert_in!(input, message)
      Ricer::Plugins::Poll::Question.open.find(input) rescue fail(:err_not_open)
    end

    def convert_out!(question, message)
      question.text
    end
    
  end
end
