module Ricer::Plugins::Conf
  class ChannelLang < Ricer::Plugin
    
    trigger_is :clang
    
    has_usage :execute_show, '', scope: :channel
    has_usage :execute_show, '<channel>'

    has_usage :execute_set, '<language>', scope: :channel,  permission: :operator
    has_usage :execute_set_channel, '<channel> <language>', permission: :ircop
    
    def execute_show(channel=nil)
      channel ||= self.channel
      rply(:msg_show,
        iso: channel.locale.to_label,
        channel: channel.displayname,
        available: UserLang.available,
      )
    end

    def execute_set(language)
      execute_set_channel(channel, language)
    end
    
    def execute_set_channel(channel, language)
      have = channel.locale
      channel.locale = language
      channel.save!
      rply :msg_set,
        :channel => channel.displayname,
        :old => have.to_label,
        :new => language.to_label
    end

  end
end
