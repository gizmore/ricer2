module Ricer::Plug::Params
  class OpenQuestionParam < Base
    
    def convert_in!(input, options, message)
      Ricer::Plugins::Poll::Question.open.find(input) rescue fail(:err_not_open)
    end

    def convert_out!(question, options, message)
      question.text
    end
    
  end
end
