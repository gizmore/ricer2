module Ricer::Plug::Param
  class ServerParam < Base

    def self.get_arg(server, arg, message)
      
      server = Ricer::Irc::Server.where(:id => arg).first
      server = Ricer::Irc::Server.in_domain(arg).first if server.nil?
      server

    end
    
  end
end