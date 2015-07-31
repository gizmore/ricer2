module Ricer::Plugins::Trans
  class Trans < Ricer::Plugin
    
    trigger_is :t

    has_usage :execute, '<lang_iso[multiple=1]> <..text..>'
    def execute(locales, text)
      l = channel ? channel.locale : user.locale
      Ricer::Thread.execute do |thread|
        gtrans = Ricer::GTrans.new(text)
        locales.each do |locale|
          translation = gtrans.to(locale.iso)
          rply(:msg_translated,
            language: locale.to_label,
            translation: translation[:text]
          )
        end
      end
    end

    has_usage :execute_auto, '<..text..>'
    def execute_auto(text)
      locale = channel ? channel.locale : user.locale
      execute([locale], text)
    end
    
  end
end
