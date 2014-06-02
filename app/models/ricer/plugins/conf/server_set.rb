module Ricer::Plugins::Conf
  class ServerSet < Ricer::Plugin
    
    trigger_is 'server set'
    permission_is :responsible
    
    def columns
      ServerShow.columns
    end
    
    def execute
      server = argc == 1 ? self.server : load_server(argv[0])
      rplyr :err_server if server.nil?
      var = argv[-2]
      val = argv[-1]
      columns = self.class.columns
      rplyp :err_server_column, columns:columns.join(', ') unless columns.include?(var)
      server[var] = val
      server.save!
      rply :msg_set, server:server.displayname, varname:var, value:server[var]
    end
    
  end
end
