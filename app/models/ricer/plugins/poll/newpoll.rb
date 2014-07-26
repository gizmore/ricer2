module Ricer::Plugins::Poll
  class Newpoll < Ricer::Plugin
    
    trigger_is :'+poll'

    has_setting name: :announce, scope: :user,    permission: :halfop, type: :boolean, default: false
    has_setting name: :announce, scope: :channel, permission: :halfop, type: :boolean, default: true
    
    has_usage :execute, '<..question|answer1|answer2|..>'
    def execute(message)
      
      parts = message.split('|')
      question = parts.shift
      parts = parts.unique
      return rply :err_no_answers if parts.length < 2
      
      survey = Survey::Survey.new(
        :name => "Ricer2 Poll",
        :description => "Created by ricer2 plugin. One survey, one question",
        :attempts_number => 1,
      )
      
      question = survey.questions.new(
        :text => question,
      )
      
      parts.each do |optiontext|
        option = question.options.new(
          :text => optiontext,
          :correct => true,
          :weight => 1,
        )
      end
      
    end

  end
end
