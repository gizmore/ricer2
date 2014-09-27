module Ricer::Plug::Params
  class ServerParam < BaseOnline

    DEFAULT_OPTIONS = { online: nil, multiple: '0', connectors: '*' }

    def default_options; DEFAULT_OPTIONS; end

    def connector_options
      conn = options[:connectors]
      return nil if conn.nil? || conn.empty? || (conn == '*')
      options[:connectors].split(/ *[,;]+ */).collect{|c|c}.reject{|c|c.empty?}
    end
    
    def convert_in!(input, message)
      input = input.gsub(/\s+/, '').gsub(';', ',')
      # return self.servers if ",#{input},".index(",*,")
      servers = []
      connectors = connector_options
      input.split(',').each do |arg|
        input_id = arg.to_i rescue 0
        connector = arg.downcase
        self.servers.all.each do |server|
          if (!arg.empty?) && (connectors.nil? || connectors.include?(server.connector))
            if ((arg == '*') || (input_id == server.id) || (URI::Generic.domain(server.url).index(input)) || (server.connector == connector))
              servers.push(server)
            end
          end
        end
      end
      servers.sort do |a,b|
        return 1 if b == message.server
        return 0
      end
      if o = online_option
        servers.reject!{|s| s.online != o }
      end
      failed_input if servers.length == 0
      fail('ricer.plug.params.err_ambigious') unless options_multiple || (servers.length == 1)
      options_multiple ? servers : servers.first
    end

    def convert_out!(server, message)
      server.displayname
    end
    
  end
end
