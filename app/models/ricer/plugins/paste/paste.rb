module Ricer::Plugins::Paste
  class Paste < Ricer::Plugin
    
    trigger_is :paste
    permission_is :voice
    
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
    
    def pastebin_title
      t :pastebin_title, user: user.name, date: l(Time.now)
    end

    def send_pastebin(title, content, lines, pastelang='text', langkey=:msg_pasted_this)
      Ricer::Thread.execute do
        begin
          paste = Pile::Cxg.new({user_id:user.id}).upload(title, content, pastelang)
          raise Ricer::ExecutionException.new("No URI") if paste.url.nil? || paste.url.empty?
          rply(langkey,
            url: paste.url,
            title: title,
            size: lib.human_filesize(paste.size),
            count: lines,
          )
        rescue StandardError => e
          rply :err_paste_failed, reason: e.to_s
        end
      end
    end
    
  end
end
