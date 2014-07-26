module Ricer::Plugins::Conf
  class ServerShow < Ricer::Plugin
    
    trigger_is 'server show'
    permission_is :responsible
    
    def self.config_columns
      Ricer::Irc::Server.column_names - ['id', 'bot_id', 'connector', 'online', 'created_at', 'updated_at']
    end

    has_usage :execute, '<server> <variable>', :scope => :user
    def execute(server, var)
      columns = self.class.config_columns
      return rplyp :err_server_column, columns:columns.join(', ') unless columns.include?(var.to_s)
      rply :msg_show, server: server.displayname, varname: var, value: server[var]
    end
    
    has_usage :execute_, '<variable>'
    def execute_(var)
      execute(self.server, var)
    end
    
  end
end
