module Ricer::Plugins::Conf
  class ServerLang < Ricer::Plugin
    
    trigger_is :slang
    
    has_usage :execute_show, ''
    has_usage :execute_show, '<server>'

    has_usage :execute_set, '<language>', permission: :ircop
    has_usage :execute_set_server, '<server> <language>', permission: :ircop
    
    def execute_show(server=nil)
      server ||= self.server
      rply(:msg_show,
        iso: server.locale.to_label,
        server: server.displayname,
        available: UserLang.available,
      )
    end

    def execute_set(language)
      execute_set_server(server, language)
    end
    
    def execute_set_server(server, language)
      have = server.locale
      server.server = language
      server.save!
      rply(:msg_set,
        :server => server.displayname,
        :old => have.to_label,
        :new => language.to_label,
      )
    end

  end
end
