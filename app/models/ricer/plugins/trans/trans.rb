module Ricer::Plugins::Trans
  class Trans < Ricer::Plugin
    
    trigger_is :t

    has_usage :execute_from, '<lang_iso[multiple=0]> <lang_iso[multiple=1]> <..text..>'
    def execute_from(from_iso, isos, text)
      Ricer::Thread.execute do
        gtrans = Ricer::GTrans.new(text, from_iso)
        isos.each do |iso|
          execute_single(gtrans, iso)
        end
      end
    end

    has_usage :execute, '<lang_iso[multiple=1]> <..text..>'
    def execute(isos, text)
      execute_from(Ricer::GTrans::AUTO, isos, text)
    end

    has_usage :execute_auto, '<..text..>'
    def execute_auto(text)
      locale = channel ? channel.locale : user.locale
      execute([locale.iso], text)
    end
    
    private

    def execute_single(gtrans, target_iso)
      trans = gtrans.to(target_iso)
      if trans[:text]
        rply(:msg_translated, from: trans[:iso], to: trans[:target_iso], text: trans[:text])
      elsif (trans[:target_iso] == trans[:iso])
        rply(:err_same, to: target_iso)
      else
        rply(:err_translate, from: trans[:iso], to: trans[:target_iso])
      end
    end
    
  end
end
