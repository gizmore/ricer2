module Ricer::Plugins::Trans
  class Interpreter < Ricer::Plugin
    
    trigger_is :interpreter
    
    has_setting name: :translating, type: :string, scope: :user,    permission: :loggedin, default: "0" 
    has_setting name: :translating, type: :string, scope: :channel, permission: :admin,    default: "0" 

    has_usage :execute_toggle, '<boolean>'
    def execute_toggle(bool)
      bool ? execute_enable() : execute_disable()
    end
    
    def execute_enable
      save_interpreting('1')
      rply(:msg_enabled, languages: display_interpreter_languages)
    end
    
    def execute_disable
      save_interpreting('0')
      rply(:msg_disabled, languages: display_interpreter_languages)
    end
    
    def save_interpreting(on_off='1')
      save_setting(:translating, on_off + get_setting(:translating).substr(1));
    end
    
    def display_interpreter_languages
      "Aaaa"
    end

    has_usage '<lang_iso[multiple=1]>'
    def execute(locales)
      isos = locales.collect do |locale|; locale.iso; end
      save_setting(:translating, '1'+isos.join(','));
    end
    
    def is_interpreting?
      get_setting(:translating).start_with?('1')
    end
    
    def interpreter_isos
      get_setting(:translating).substr(1).split(',')
    end
    
    def interpreter_locales
      interpreter_isos.map do |iso|; Ricer::Locale.by_iso(iso); end
    end
    
    def on_privmsg()
      return if channel && @message.is_triggered?
      return unless is_interpreting?
        interpreter_locales.each do |locale|
      end
    end
    
  end
end
