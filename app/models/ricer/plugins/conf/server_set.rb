module Ricer::Plugins::Conf
  class ServerSet < Ricer::Plugin
    
    trigger_is 'server set'
    permission_is :responsible

    has_usage :execute_set, '<variable> <value>'
    def execute_set(var, value)
      execute_set_server(server, var, value)
    end

    has_usage :execute_set_server, '<server> <variable> <value>'
    def execute_set_server(server, var, value)
      columns = ServerShow.config_columns
      return rplyp :err_server_column, columns: columns.join(', ') unless columns.include?(var.to_s)
      old_value,server[var] = server[var],value
      server.save!
      rply :msg_set, server:server.displayname, varname:var, value:server[var], old_value:old_value
    end
    
    has_usage :execute_show, '<variable>'
    def execute_show(var, value)
      execute_show_server(server, var, value)
    end

    has_usage :execute_show_server, '<server> <variable>'
    def execute_show_server(server, var, value)
      rply :msg_show, server:server.displayname, varname:var, value:server[var]
    end
    
  end
end
