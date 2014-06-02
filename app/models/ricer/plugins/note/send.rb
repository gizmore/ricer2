module Ricer::Plugins::Note
  class Send < Ricer::Plugin

    trigger_is :send

    has_usage :execute, '<user> <..message..>'
    def execute(receiver, text)
      
      return rply :err_send_self if sender == receiver 
      
      message = Message.create!({
        sender: sender,
        receiver: receiver,
        text: text,
        read_at: nil,
        sent_at: Time.now,
      })
      
      if receiver.online?
        message_to(receiver, message.display_show_item)
        rply :msg_instant
      else
        rply :msg_stored
      end
      
    end

  end
end
