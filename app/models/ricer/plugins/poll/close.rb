module Ricer::Plugins::Poll
  class Close < Ricer::Plugin
    
    def poll_plugin; get_plugin('Poll/Poll'); end
    def vote_plugin; get_plugin('Poll/Vote'); end
    def max_age_cut; poll_plugin.max_age_cut; end
    
    trigger_is '-poll'

    has_usage '<open_question>'
    def execute(question)
      return rply :err_not_allowed unless question.can_close?(sender, max_age_cut)
      close_question(question)
      rply :msg_closed, type:question.type_label, qid:question.id, question:question.text, asker:question.creator.displayname
    end
    
    def close_question(question)
      question.close!
      vote_plugin.cheat_clear(question)
      if question.is_answered_freely?
        announce_free_question_closed(question)
      else
        announce_poll_closed(question)
      end
    end
    
    private
    
    #################################
    ### Poll,  Multi and HotOrNot ###
    #################################
    def announce_poll_closed(question)
      poll_plugin.announce_targets do |target|
        target.localize!.send_message(poll_closed_message(question))
      end
    end

    def poll_closed_message(question)
      t(:msg_poll_closed,
        :type => question.type_label,
        :qid => question.id,
        :question => question.text,
        :asker => question.creator.displayname,
        :outcome => question.display_outcome)
    end
    
    ######################
    ### Free Questions ###
    ######################
    def announce_free_question_closed(question)
      content = pastebin_title(question)
      content += "\n\n"
      question.answers.each do |answer|
        content += "<#{answer.user.displayname}>: \"#{answer.option.text}\"\n"
      end
      send_pastebin(question, content)
    end
    
    def pastebin_title(question)
      t(:paste_title,
        type:question.type_label,
        qid:question.id,
        question:question.text,
        asker:question.creator.displayname,
        date:l(question.created_at))
    end
    
    def send_pastebin(question, content)
      Ricer::Thread.execute do
        paste = Pile::Cxg.new({user_id:question.user_id}).upload(pastebin_title(question), content, 'text')
        poll_plugin.announce_targets do |target|
          target.localize!.send_message(t(:paste_message,
            type:question.type_label,
            qid:question.id,
            question:question.text,
            asker:question.creator.displayname,
            url:paste.url,
            num_answers: question.answers.count
        ))
        end
      end
    end

  end
end
