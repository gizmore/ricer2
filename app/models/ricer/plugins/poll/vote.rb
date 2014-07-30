module Ricer::Plugins::Poll
  class Vote < Ricer::Plugin
    
    trigger_is :answer
    
    has_cheating_detection
    
    def cheat_detection_message; t(:err_cheating); end

    has_usage :execute, '<open_question> <..message..>'
    def execute(question, message)
      # Validation
      return rply :err_answer_self if question.creator == sender
      cheat_detection!(question)
      return rply :err_answer_twice if question.has_user_voted?(sender)
      # Call vote handler
      case question.poll_type
      when Question::POLL;      execute_vote_for_poll(question, message, 1)
      when Question::MULTI;     execute_vote_for_poll(question, message, 20)
      when Question::RATE;      execute_vote_for_rate(question, message)
      when Question::QUESTION;  execute_answer_freely(question, message)
      end
    end
    
    ######################
    ### Poll and Multi ###
    ######################
    def execute_vote_for_poll(question, message, max_choices)
      
      choices = []
      # First sanity
      num_options = question.options.count
      message.split(',').each do |number|
        number = number.to_i
        failed_input(:err_invalid_choice, min:1, max:num_options) unless number.between?(1, num_options)
        choices.push(number-1)
      end
      # Second sanity
      choices.uniq!
      failed_input(:err_no_choice) if choices.length < 1
      failed_input(:err_no_multi) if choices.length > max_choices
      # Loop and check index for answer choice creation
      question.options.each_with_index do |i, option|
        option.answers.create!({user: sender, option: option}) if (choices.include?(i))
      end
      # Done
      complete_voting_with_feedback(question)
    end
    
    #################
    ### HotOrNot! ###
    #################
    def execute_vote_for_rate(question, number)
      number = number.to_i
      failed_input(:err_rate_range, min:1, max:10) unless number.between?(1, 10)
      ActiveRecord::Base.transaction do
        option = question.options.find_or_create_by({int_value: number})
        answer = option.answers.create!({user: sender, option: option})
      end
      complete_voting_with_feedback(question)
    end

    def complete_voting_with_feedback(question)
      # Insert hostmask to memory
      cheat_attempt(question)
      # Feedback that it worked
      rply :msg_vote_counted
      # Feedback to creator
      question.creator.localize!.send_message(
        t(:msg_vote_received, server:sender.server.displayname))
    end

    #####################
    ### Free Question ###
    #####################
    def execute_answer_freely(question, message)
      # Create free-text answer
      ActiveRecord::Base.transaction do 
        option = question.options.create!({choice: message})
        answer = option.answers.create!({user: sender, option: option})
        # Insert hostmask to memory
        cheat_attempt(question)
        # Tell the asker directly
        announce_freetext_to_creator(question, message)
      end
    end
    
    def announce_freetext_to_creator(question, message)
      question.creator.localize!.send_message(
        announce_freely_text(question, message))
    end
    
    def announce_freely_text(question, message)
      t(:msg_freetext_answer,
        answerer: sender.displayname,
        question: question.text,
        answer: message
      )
    end

  end
end
