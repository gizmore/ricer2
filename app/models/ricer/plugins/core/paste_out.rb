module Ricer::Plugins::Core
  class PasteOut < Ricer::Plugin
    
    has_priority 100 # After all is done
    
    trigger_is :paste
    
    has_setting name: :max_length, type: :integer, scope: :server, permission: :operator, default: 12
    
#   has_usage :execute_with_language, '<programming_language> <..text..>'
#   def execute_with_language(programming_language)
#   end
 
    has_usage '<..text..>'
    def execute(content)
      execute_upload(content)
    end
    
    def execute_upload(content, pastelang='text', title=nil, langkey=:msg_pasted_it)
      send_pastebin(title||pastebin_title, content, content.count("\n"), 'text', langkey)
    end
    
    def max_length
      get_setting(:max_length)
    end
    
    def on_privmsg
      send_queue_as_pastebin if user.get_queue.length > max_length rescue nil
    end
    
    def send_queue_as_pastebin
      messages = user.flush_queue # Fetch and purge user queue
      messages.each do |message|  # Let ricer know that the messages have been sent.
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
      t :pasteout_title, user: user.name, date: l(Time.now), command: current_message.args[1]
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
        begin
          paste = Pile::Cxg.new({user_id:user.id}).upload(title, content, pastelang)
          raise if paste.url.nil?
          rply langkey,
            url: paste.url,
            title: title,
            size: lib.human_filesize(paste.size),
            count: lines
        rescue Exception => e
          rply :err_paste_failed, reason: e.to_s
        end
      end
    end
    
  end
end
