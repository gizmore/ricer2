module Ricer::Plugins::Conf
  class ServerShow < Ricer::Plugin
    
    trigger_is 'server show'
    permission_is :responsible
    
    def self.colomns
      Server.column_names - [:id, :connector, :created_at, :updated_at]
    end
    
    def execute
      server = argc == 1 ? self.server : load_server(argv[0])
      rplyr :err_server if server.nil?
      var = argv[-1]
      columns = self.class.columns
      rplyp :err_server_column, columns:columns.join(', ') unless columns.include?(var)
      rply :msg_show, server:server.displayname, varname:var, value:server[var]
    end
    
  end
end
