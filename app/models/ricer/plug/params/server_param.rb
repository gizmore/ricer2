module Ricer::Plug::Params
  class ServerParam < BaseOnline

    def default_options; { online: nil, multiple: '0', connectors: '*' }; end

    def connector_options
      conn = options[:connectors]
      return nil if conn.nil? || conn.empty? || (conn == '*')
      options[:connectors].split(/ *[,;]+ */).collect{|c|c}.reject{|c|c.empty?}
    end
    
    def convert_in!(input, message)
      input = input.gsub(/\s+/, '').gsub(';', ',')
      servers = []
      connectors = connector_options
      input.split(',').each do |arg|
        input_id = arg.to_i rescue 0
        connector = arg.downcase
        Ricer::Irc::Server.all.each do |server|
          if (!arg.empty?) && (connectors.nil? || connectors.include?(server.connector))
            if ((arg == '*') || (input_id == server.id) || (URI::Generic.domain(server.url).index(arg)))
              servers.push(server)
            end
          end
        end
      end
      # servers.sort do |a,b|
        # return 1 if a.id == message.server.id rescue 0
        # return 0
      # end
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
