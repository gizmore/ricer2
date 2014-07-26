module Ricer::Plug::Params
  class PollParam < Base
    
    def convert_in!(input, options, message)
      Survey::Survey.find(input) rescue failed_input
    end

    def convert_out!(survey, options, message)
      survey.questions.first.text
    end
    
  end
end
