module Ricer::Plug::Params
  class ServerParam < Base

    def convert_in!(input, options, message)
      server = Ricer::Irc::Server.where(:id => arg).first
      server = Ricer::Irc::Server.in_domain(arg).first if server.nil?
      input_failed if server.nil?
      server
    end

    def convert_out!(value, options, message)
      value.displayname
    end
    
  end
end