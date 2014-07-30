module Ricer::Plugins::Conf
  class ServerSet < Ricer::Plugin
    
    trigger_is 'server set'
    permission_is :responsible
    
    has_usage :execute, '<server> <variable> <value>'
    def execute(server, var, value)
      columns = ServerShow.config_columns
      return rplyp :err_server_column, columns: columns.join(', ') unless columns.include?(var.to_s)
      old_value,server[var] = server[var],value
      server.save!
      rply :msg_set, server:server.displayname, varname:var, value:server[var], old_value:old_value
    end
    
    has_usage :execute_, '<variable> <value>'
    def execute_(var, value)
      execute(self.server, var, value)
    end
    
  end
end
