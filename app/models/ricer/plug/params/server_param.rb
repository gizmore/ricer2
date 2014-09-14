module Ricer::Plug::Params
  class ServerParam < Base

    def convert_in!(input, message)
      server = Ricer::Irc::Server.where(:id => input).first
      server = Ricer::Irc::Server.in_domain(input).first if server.nil?
      failed_input if server.nil?
      server
    end

    def convert_out!(value, message)
      value.displayname
    end
    
  end
end