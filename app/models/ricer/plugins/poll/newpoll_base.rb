module Ricer::Plugins::Poll
  class NewpollBase < Ricer::Plugin

    protected
    
    def max_age; get_plugin('Poll/Poll').max_age; end
    def max_options; get_plugin('Poll/Poll').max_options; end

    # Create poll or multi    
    def create_poll(message, poll_type)
      parts = message.split('|')
      parts.each { |part| part.trim!(' ') }
      question, options = parts.shift, parts.uniq
      return rplyp :err_no_options if options.length < 2
      question = Question.create!({
        text: question,
        user_id: sender.id,
        poll_type: poll_type,
      })
      options.each do |choice|
        question.options.create!({
          choice: choice
        })
      end
      announce(question)
    end
    
    
    # Generic announce    
    def announce(question)
      
      usercount = channelcount = 0
      
      # Announce to subscribers
      get_plugin('Poll/Poll').announce_targets do |target|
        usercount += target.is_a?(Ricer::Irc::User) ? 1 : 0
        channelcount += target.is_a?(Ricer::Irc::Channel) ? 1 : 0
        target.localize!.send_message(announce_message(question))
      end
      
      # Announce to asker
      rplyp :msg_created,
        type: question.type_label,
        channelcount: channelcount,
        usercount: usercount,
        tc: close_trigger(question),
        max_age: display_max_age
    end
    
    private
    
    def announce_message(question)
      case question.poll_type
      when Question::POLL
        poll_announce_message(question)
      when Question::MULTI
        poll_announce_message(question)
      when Question::RATE
        valuable_announce_message(question)
      when Question::QUESTION
        question_announce_message(question)
      end
    end

    ### Helper
    def display_max_age
      lib.human_duration(max_age)
    end
    def close_trigger(question)
      "$TRIGGER$#{get_plugin('Poll/Close').trigger} #{question.id}"
    end
    def answer_trigger(question)
      "$TRIGGER$#{get_plugin('Poll/Vote').trigger} #{question.id}"
    end
    
    ### Choice Helper
    def poll_announce_choices(question)
      i = 0
      choices = []
      question.options.each do |option|
        i += 1
        choices.push("#{i})_#{option.choice}")
      end
      choices.join(', ')
    end

    ### Types
    def poll_announce_message(question)
      t(:msg_announce,
        user: question.creator.displayname,
        question: question.text,
        choices: poll_announce_choices(question),
        ta: answer_trigger(question))
    end
    
    def valuable_announce_message(question)
      t(:msg_announce,
        user: question.creator.displayname,
        question: question.text,
        ta: answer_trigger(question),
        min: 1, max: 10)
    end

    def question_announce_message(question)
      t(:msg_announce,
        user: question.creator.displayname,
        question: question.text,
        ta: answer_trigger(question))
    end

  end
end
