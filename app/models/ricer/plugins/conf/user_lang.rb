module Ricer::Plugins::Conf
  class UserLang < Ricer::Plugin
    
    trigger_is :lang
    
    def self.available
      out = []
      Ricer::Locale.all.each do |l|
        out.push(l.iso)
      end
      out.join(', ')
    end
    
    has_usage :execute_set_user_language, '<language>' 
    has_usage :execute_show_user_language
    
    def execute_show_user_language
      rply :msg_show, :iso => user.locale.to_label, :available => self.class.available
    end
    
    def execute_set_user_language(language)
      old_language = user.locale
      user.locale = language
      user.save!
      rply :msg_set, :old => old_language.to_label, :new => language.to_label
    end

  end
end
