module Ricer::Plugins::Note
  class Send < Ricer::Plugin

    trigger_is :send

    has_usage '<user> <..message..>'
    
    def execute(receiver, text)
      
      return rply :err_send_self if sender == receiver 
      
      note = Message.create!({
        sender: sender,
        receiver: receiver,
        message: text,
      })
      
      if receiver.online?
        message_to(receiver, note.display_show_item)
        rply :msg_instant
      else
        rply :msg_stored
      end
      
    end

  end
end
