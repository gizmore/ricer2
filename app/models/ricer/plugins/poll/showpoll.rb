module Ricer::Plugins::Poll
  class Showpoll < Ricer::Plugin
    
    is_show_trigger :showpoll, :for => Ricer::Plugins::Poll::Question

    def display_show_item(question, number)
      question.open? ?
        display_open_item(question, number) :
        display_closed_item(question, number)
    end

    def time_left(question)
      max_age = get_plugin('Poll/Poll').max_age
      left = max_age - (Time.now - question.created_at)
      lib.human_duration(left) 
    end
    
    def display_open_item(question, number)
      t(:msg_show_open,
        type: question.type_label,
        number: number,
        asker: question.creator.displayname,
        time_left: time_left(question),
        question: question.text,
        count: question.answers.count
      )
    end
    
    def display_closed_item(question, number)
      t(:msg_show_closed,
        type: question.type_label,
        number: number,
        asker: question.creator.displayname,
        question: question.text,
        votes: question.answers.count,
        outcome: question.display_outcome,
        date: l(question.closed_at)
      )
    end

  end
end
