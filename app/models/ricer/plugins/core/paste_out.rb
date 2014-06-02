module Ricer::Plugins::Core
  class PasteOut < Ricer::Plugin
    
    has_priority 100 # After all is done
    
    trigger_is :paste
    
    has_setting name: :max_length, type: :integer, scope: :user, permission: :operator, default: 12
    
    has_usage :execute, '<..text..>'
#    has_usage :execute, '[<programming_language>] <..text..>'
    def execute(content)
      send_pastebin(pastebin_title, content, content.length, 'text', :msg_pasted_it)
    end
    
    def max_length
      get_setting(:max_length, :user)
    end
    
    def on_privmsg
      send_queue_as_pastebin if user.get_queue.length > max_length
    end
    
    def send_queue_as_pastebin
      messages = user.flush_queue
      messages.each do |message|
        server.ricer_replies_to(message)
      end
      build_and_send_pastepin(messages)
    end
    
    def build_and_send_pastepin(messages)
      send_pastebin(pasteout_title(messages), pastebin_message(messages), messages.length)
    end
    
    def pastebin_title
      t :pastebin_title, user: user.name, date: l(Time.now)
    end
    def pasteout_title(messages)
      t :pasteout_title, user: user.name, date: l(Time.now), command: @message.args[1]
    end

    def pastebin_message(messages)
      text = ''
      messages.each do |message|
        text += message.reply_data
        text += "\n"
      end
      text
    end
    
    def send_pastebin(title, content, lines, pastelang='text', langkey=:msg_pasted_this)
      Ricer::Thread.execute do
        paste = Pile::Cxg.new({user_id:user.id}).upload(title, content, pastelang)
        rply langkey, url: paste.url, size: paste.size, count: lines
      end
    end
    
  end
end
