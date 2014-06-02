module Ricer::Plugins::Conf
  class ChannelLang < Ricer::Plugin
    
    trigger_is :clang
    
    has_usage :execute_set, '<language>'
    has_usage :execute_show
    
    def execute_show
      rply :msg_show, :iso => channel.locale.to_label, :available => UserLang.available
    end
    
    def execute_set(language)
      have = channel.locale
      channel.locale = language
      channel.save!
      rply :msg_set, :old => have.to_label, :new => language.to_label
    end

  end
end
