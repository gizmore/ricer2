module Ricer::Plugins::Conf
  class ServerEncoding < Ricer::Plugin
    
    trigger_is :sencoding
    
    has_usage :execute_show, ''
    has_usage :execute_show, '<server>'

    has_usage :execute_set, '<encoding>', permission: :ircop
    has_usage :execute_set_server, '<server> <encoding>', permission: :ircop
    
    def execute_show(server=nil)
      server ||= self.server
      rply(:msg_show,
        iso: server.encoding.to_label,
        server: server.displayname,
      )
    end

    def execute_set(encoding)
      execute_set_server(server, encoding)
    end
    
    def execute_set_server(server, encoding)
      have = server.encoding
      server.encoding = encoding
      server.save!
      rply(:msg_set,
        :server => server.displayname,
        :old => have.to_label,
        :new => encoding.to_label,
      )
    end

  end
end
